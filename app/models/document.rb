# -*- encoding : utf-8 -*-
require 'csv'
require "net/http"

class Document < ActiveRecord::Base
  has_many :shingle_signatures, :dependent => :destroy, :order => 'position_start asc'
  has_many :i_match_signatures, :dependent => :destroy
  has_many :min_hash_signatures, :dependent => :destroy
  has_many :super_shingle_signatures, :dependent => :destroy
  has_many :mega_shingle_signatures, :dependent => :destroy
  has_many :long_sent_signatures, :dependent => :destroy
  has_one :rewrite_document

  validates :content, :presence => true

  after_create :create_signatures
  after_initialize :initialize_for_match

  attr_accessor :similarity, :paint, :matched_documents

  def initialize_for_match
    @similarity = 0
    @paint = []
    @matched_documents = []
  end

  def create_signatures
    Document.benchmark('create_shingle_signatures') do
      create_shingle_signatures
    end
    Document.benchmark('create_min_hash_signatures') do
      create_min_hash_signatures
    end
    Document.benchmark('create_super_shingle_signatures') do
      create_super_shingle_signatures
    end
    Document.benchmark('create_mega_shingle_signatures') do
      create_mega_shingle_signatures
    end
    Document.benchmark('create_long_sent_signatures') do
      create_long_sent_signatures
    end
  end

  def build_long_sent_signatures
    if long_sent_signatures.empty?
      max1, max2 = '', ''

      content.split(/[[:cntrl:][:punct:]]/).each  do |sent|
        if max1.length < sent.length
          max1 = sent
          max2 = max1
        end
      end

      long_sent_signatures.new(:token => Digest::MD5.hexdigest([max1, max2].sort.join))
    end
  end

  def build_mega_shingle_signatures
    if mega_shingle_signatures.empty?
      generate_combinations_for_mega_shingle do |mega_shingle|
        mega_shingle_signatures.new(:token => Digest::MD5.hexdigest(mega_shingle.join))
      end
    end
  end

  def build_super_shingle_signatures
    if super_shingle_signatures.empty?
      super_shingle_signatures.new(:token => Digest::MD5.hexdigest(min_hash_signatures[0...14].map(&:token).join))
      super_shingle_signatures.new(:token => Digest::MD5.hexdigest(min_hash_signatures[14...28].map(&:token).join))
      super_shingle_signatures.new(:token => Digest::MD5.hexdigest(min_hash_signatures[28...42].map(&:token).join))
      super_shingle_signatures.new(:token => Digest::MD5.hexdigest(min_hash_signatures[42...56].map(&:token).join))
      super_shingle_signatures.new(:token => Digest::MD5.hexdigest(min_hash_signatures[56...70].map(&:token).join))
      super_shingle_signatures.new(:token => Digest::MD5.hexdigest(min_hash_signatures[70...84].map(&:token).join))
    end
  end

  def build_min_hash_signatures
    if min_hash_signatures.empty?
      MinWise::find_min(shingle_signatures.map(&:token)).each do |min|
        min_hash_signatures.new(:token => Digest::MD5.hexdigest(min.to_s))
      end
    end
  end

  def build_shingle_signatures
    if shingle_signatures.empty?
      shingling = Shingling.new(
        content,
        :replace_chars => Diploma::Application::ALPHABETIC,
        :stop_words => Text::STOP_WORDS,
        :shingle_length => ShingleSignature::SHNINGLE_LENGTH,
        :downcase => true
      )

      shingling.each_shingles do |shingle, position_start, position_end|
        shingle_signatures.new(
          :token => Digest::MD5.hexdigest(shingle),
          :position_start => position_start,
          :position_end => position_end
        )
      end
    end
  end

  def html
    ActionController::Base.render_to_string('admin/main/types/shingle', :layout => false)
  end

  def build_i_match_signatures
    current_words = content.split(/[^А-ЯЁа-яё]+/).to_set
    i_match_signatures.new(:token => Digest::MD5.hexdigest((current_words & Diploma::Application::DICTIONARY).to_a.sort.join))
  end

  def similarity_super_shingle_signatures
    @matched_documents = Document.select("DISTINCT ON (documents.id) documents.*").joins(:super_shingle_signatures).where(:"super_shingle_signatures.token" => super_shingle_signatures.map(&:token).map(&:to_s))#.group(:"documents.id")
    @similarity = @matched_documents.size >= 2 ? 95 : 0
  end

  def similarity_long_sent_signatures
    @matched_documents = Document.select("DISTINCT ON (documents.id) documents.*").joins(:long_sent_signatures).where(:"long_sent_signatures.token" => long_sent_signatures.map(&:token).map(&:to_s))#.group(:"documents.id")
    @similarity = @matched_documents.empty? ? 0 : 100
  end

  def similarity_i_match_signatures
    @matched_documents = Document.select("DISTINCT ON (documents.id) documents.*").joins(:i_match_signatures).where(:"i_match_signatures.token" => i_match_signatures.map(&:token).map(&:to_s))#.group(:"documents.id")
    @similarity = @matched_documents.empty? ? 0 : 100
  end

  def similarity_mega_shingle_signatures
    @matched_documents = Document.select("DISTINCT ON (documents.id) documents.*").joins(:mega_shingle_signatures).where(:"mega_shingle_signatures.token" => mega_shingle_signatures.map(&:token).map(&:to_s))#.group(:"documents.id")
    @similarity = @matched_documents.size >= 2 ? 95 : 0
  end

  def similarity_min_hash_signatures
    equal_count = 0.0
    global_equal_count = 0.0
    min_wise_function_is_equal = {}
    @matched_documents = Document.select("DISTINCT ON (documents.id) documents.*").joins(:min_hash_signatures).where(:"min_hash_signatures.token" => min_hash_signatures.map(&:token).map(&:to_s))#.group(:"documents.id")

    matched_documents.each do |document|
      MinWise::FUNCTION_NUMBER.times do |i|
        if min_hash_signatures[i].token.to_s == document.min_hash_signatures[i].token.to_s
          equal_count += 1
          unless min_wise_function_is_equal.has_key?(i)
            global_equal_count += 1
            min_wise_function_is_equal.merge! i => true
          end
        end
      end
      document.similarity = (equal_count / MinWise::FUNCTION_NUMBER * 100).round(0)
      equal_count = 0.0
    end

    @similarity = (global_equal_count / MinWise::FUNCTION_NUMBER * 100).round(0)
  end

  def similarity_shingle_signatures
    number_matched = 0
    hash_shingle_signatures = nil
    in_database = []
    local_matched_documents = {}

    # Для больших документов быстрее сделать из shingle_signatures хеш и потом по нему искать
    Document.benchmark("Create hash from array for shingle_signatures") do
      hash_shingle_signatures = Hash[shingle_signatures.map {|s| [s.token, s]}]
    end

    Document.benchmark("shingle_match") do
      in_database = ShingleSignature.where(:token => shingle_signatures.map(&:token))
    end

    Document.benchmark("Coloring") do
      in_database.each do |shingle_match|
        shingle_signature = hash_shingle_signatures[shingle_match.token]
        number_matched += 1
        color = ColorForDocument.get(shingle_match.document_id)

        @paint << Coloring.new(:token => shingle_signature.token,
                               :position_start => shingle_signature.position_start,
                               :position_end => shingle_signature.position_end,
                               :color => color)

        matched_document = local_matched_documents[shingle_match.document_id]
        if matched_document.blank?
          local_matched_documents.merge! shingle_match.document_id => shingle_match.document
          @matched_documents << shingle_match.document
          matched_document = shingle_match.document
        end
        matched_document.paint << Coloring.new(:token => shingle_signature.token,
                                               :position_start => shingle_match.position_start,
                                               :position_end => shingle_match.position_end,
                                               :color => color)
      end
    end

    @similarity =  number_matched > 0 ? (number_matched * 100.0 / (shingle_signatures.size)).round(0) : 0
  end

  def paint_sort
    @paint.sort! { |a, b| a.position_start <=> b.position_start }
  end

  def create_super_shingle_signatures
    build_super_shingle_signatures
    super_shingle_signatures.map(&:save)
  end

  def create_mega_shingle_signatures
    build_mega_shingle_signatures
    mega_shingle_signatures.map(&:save)
  end

  def create_min_hash_signatures
    build_min_hash_signatures
    min_hash_signatures.map(&:save)
  end

  def create_i_match_signatures
    build_i_match_signatures
    i_match_signatures.map(&:save)
  end

  def create_long_sent_signatures
    build_long_sent_signatures
    long_sent_signatures.map(&:save)
  end

  def create_shingle_signatures
    build_shingle_signatures
    conn = ActiveRecord::Base.connection_pool.checkout
    raw = conn.raw_connection
    in_database = ShingleSignature.where(:token => shingle_signatures.map(&:token))
    tmp = in_database.map(&:token).to_set

    raw.exec("COPY shingle_signatures (token, position_start, position_end, document_id) FROM STDIN DELIMITERS ','")
    shingle_signatures.each do |shingle_signature|
      unless tmp.include?(shingle_signature.token)
        raw.put_copy_data "#{shingle_signature.token}, #{shingle_signature.position_start}, #{shingle_signature.position_end}, #{shingle_signature.document_id}\n"
        tmp.add shingle_signature.token
      end
    end
    raw.put_copy_end

    while res = raw.get_result
      # Говорят что важно
    end
    ActiveRecord::Base.connection_pool.checkin(conn)
  end

  def search_from_web
    query = query_for_search_from_web
    search_from_yandex query
    search_from_google query
  end

  def limit_word number
    tmp = 0
    index = 0
    flag = false
    while tmp < number && index < content.length
      if content[index] =~ /[ ,\.!?]/ && !flag
        tmp += 1
        flag = true
      else
        flag = false
      end
      index += 1
    end

    return index
  end

  def shuffle_sentences options = {}
    shuffle_precent = options[:shuffle_precent] || 20
    sentences = content.clone.split(/[\.!?;]/)
    shuffle_size = (sentences.size.to_f / 100 * shuffle_precent).to_i
    sentences[0...shuffle_size] = sentences[0...shuffle_size].sort_by{ rand }
    
    return sentences.join('.')
  end

  def shuffle_paragraphs options = {}
    shuffle_precent = options[:shuffle_precent] || 10
    sentences = content.clone.split(/\n/)
    shuffle_size = (sentences.size.to_f / 100 * shuffle_precent).to_i
    sentences[0...shuffle_size] = sentences[0...shuffle_size].sort_by{ rand }

    return sentences.join('.')
  end

  def alphabetic
    content.gsub(/[#{Diploma::Application::ALPHABETIC_INVERT.keys.join}]/) do |char| 
      Diploma::Application::ALPHABETIC_INVERT[char]
    end
  end

  # Не понятно откуда вылазять не UTF символы. По этому всячески их пытаемся убрать
  def rewrite options = {}
    position_start = 0
    position_end = 0
    rewrite_content = ''
    ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
    length = (options[:content_length] ? content.length / 100.0 * options[:content_length] : content.length).to_i
    Rails.logger.debug { "length: #{length}" }
    while position_start <= length
      begin
        Net::HTTP::Proxy(Proxy.get, 8080, '10mnxnnK9GfM', 'MzGu0aXR9C').start('seogenerator.ru') do |http|
          position_end = (position_start + 5000) < length ? position_start + 5000 : length
          data = "text=#{CGI::escape(content[position_start...position_end])}&base=sm2&type=first&format=text"
          resp, data = http.post('/api/synonym/', data, {})
          rewrite_content += data = ic.iconv(CGI::unescape(data.gsub('\x', '%')) + ' ')[0..-2]
          position_start += 5000
          if data == 'Exceeded the limit queries from this IP address'
            puts "Exceeded the limit queries from this IP address"
            Rails.logger.debug { "Exceeded the limit queries from this IP address" }
          end
        end
      rescue Exception => e
        Rails.logger.debug { "#{e.class}:#{e.message}\n#{e.backtrace}" }
        puts "#{e.class}:#{e.message}\n#{e.backtrace}"
        sleep 1
        retry
      end
    end

    rewrite_content += content[position_end...content.length]
    return rewrite_content
  end

  private

  def search_from_yandex query
    Document.benchmark("#search_from_yandex") do
      documents = nil

      Document.benchmark("#search_from_yandex ScrapingYandex.search('\"#{query}\"')") do
        documents = ScrapingYandex.search(:query => "\"#{query}\"")
      end
      Document.benchmark("#search_from_google Document.create") do
        documents.each_pair do |link, content|
          Document.create(:content => content, :source => link) unless Document.find_by_source(link)
        end
      end
      if documents.empty?
        Document.benchmark("#search_from_yandex ScrapingYandex.search('#{query}')") do
          documents = ScrapingYandex.search(:query => query)
        end
        documents.each_pair do |link, content|
          Document.create(:content => content, :source => link) unless Document.find_by_source(link)
        end
      end
    end
  end

  def search_from_google query
    Document.benchmark("#search_from_google") do
      documents = nil

      Document.benchmark("#search_from_google ScrapingGoogle.search('\"#{query}\"')") do
        documents = ScrapingGoogle.search(:query => "\"#{query}\"")
      end
      Document.benchmark("#search_from_google Document.create") do
        documents.each_pair do |link, content|
          Document.create(:content => content, :source => link) unless Document.find_by_source(link)
        end
      end
      if documents.empty?
        Document.benchmark("#search_from_google ScrapingGoogle.search('#{query}')") do
          documents = ScrapingGoogle.search(:query => query)
        end
        documents.each_pair do |link, content|
          Document.create(:content => content, :source => link) unless Document.find_by_source(link)
        end
      end
    end
  end

  def query_for_search_from_web
    length = 300
    if content.length > length
      index = rand(content.length - length)
      index_first_word = index
      index_last_word = index + length

      while content[index_first_word] !~ /\s/ && index_first_word < content.length
        index_first_word += 1
      end

      while content[index_last_word] !~ /\s/ && index_last_word < content.length
        index_last_word += 1
      end

      position_start = index_first_word
      position_end = index_last_word
    else
      position_start = 0
      position_end = content.length
    end

    return content[position_start..position_end].strip
  end

  def generate_combinations_for_mega_shingle
    array = super_shingle_signatures.map(&:token)
    r = 2
    n = array.length
    indices = (0...r).to_a
    final = (n - r...n).to_a
    while indices != final
      yield indices.map {|k| array[k]}
      i = r - 1
      while indices[i] == n - r + i
        i -= 1
      end
      indices[i] += 1
      (i + 1...r).each do |j|
        indices[j] = indices[i] + j - i
      end
    end
    yield indices.map {|k| array[k]}
  end
end
