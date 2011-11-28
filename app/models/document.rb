# -*- encoding : utf-8 -*-
require 'csv'

class Document < ActiveRecord::Base

  has_many :shingle_signatures, :dependent => :destroy, :order => 'id'
  has_many :i_match_signatures, :dependent => :destroy, :order => 'id'
  has_many :min_hash_signatures, :dependent => :destroy, :order => 'id'
  has_many :super_shingle_signatures, :dependent => :destroy, :order => 'id'
  has_many :mega_shingle_signatures, :dependent => :destroy, :order => 'id'

  validates :content, :presence => true

  after_create :create_signatures

  attr_accessor :similar_documents_after_check, :content_after_check, :similarity, :flag_build_shingle_signatures

  def create_signatures
    create_shingle_signatures
    create_min_hash_signatures
    create_super_shingle_signatures
    create_mega_shingle_signatures
    # create_i_match_signatures
    # update_dictionary
  end

  def build_mega_shingle_signatures
    generate_combinations_for_mega_shingle do |mega_shingle|
      mega_shingle_signatures.new(:token => Digest::MD5.hexdigest(mega_shingle.join))
    end
  end

  def build_super_shingle_signatures
    super_shingle_signatures.new(:token => Digest::MD5.hexdigest(min_hash_signatures[0...14].map(&:token).join))
    super_shingle_signatures.new(:token => Digest::MD5.hexdigest(min_hash_signatures[14...28].map(&:token).join))
    super_shingle_signatures.new(:token => Digest::MD5.hexdigest(min_hash_signatures[28...42].map(&:token).join))
    super_shingle_signatures.new(:token => Digest::MD5.hexdigest(min_hash_signatures[42...56].map(&:token).join))
    super_shingle_signatures.new(:token => Digest::MD5.hexdigest(min_hash_signatures[56...70].map(&:token).join))
    super_shingle_signatures.new(:token => Digest::MD5.hexdigest(min_hash_signatures[70...84].map(&:token).join))
  end

  def build_min_hash_signatures
    MinWise::find_min(shingle_signatures.map(&:token)).each do |min|
      min_hash_signatures.new(:token => Digest::MD5.hexdigest(min.to_s))
    end
  end

  def build_shingle_signatures
    shingling = Shingling.new(
      content,
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
    self.flag_build_shingle_signatures = true
  end

  def build_i_match_signatures
    current_words = content.split(/[^[:word:]]+/).to_set
    i_match_signatures.new(:token => Digest::MD5.hexdigest((current_words & Word.where(:idf => 2..4).map(&:term).to_set).to_a.sort.join))
  end

  def similarity_super_shingle_signatures
    Document.select("DISTINCT ON (documents.id) *").joins(:super_shingle_signatures).where(:"super_shingle_signatures.token" => super_shingle_signatures.map(&:token).map(&:to_s))#.group(:"documents.id")
  end

  def similarity_i_match_signatures
    Document.select("DISTINCT ON (documents.id) *").joins(:i_match_signatures).where(:"i_match_signatures.token" => i_match_signatures.map(&:token).map(&:to_s))#.group(:"documents.id")
  end

  def similarity_mega_shingle_signatures
    Document.select("DISTINCT ON (documents.id) *").joins(:mega_shingle_signatures).where(:"mega_shingle_signatures.token" => mega_shingle_signatures.map(&:token).map(&:to_s))#.group(:"documents.id")
  end

  def similarity_min_hash_signatures
    equal_count = 0.0
    documents = Document.select("DISTINCT ON (documents.id) *").joins(:min_hash_signatures).where(:"min_hash_signatures.token" => min_hash_signatures.map(&:token).map(&:to_s))#.group(:"documents.id")

    documents.each do |document|
      MinWise::FUNCTION_NUMBER.times do |i|
        equal_count += 1 if min_hash_signatures[i].token.to_s == document.min_hash_signatures[i].token.to_s
      end
      document.similarity = equal_count / MinWise::FUNCTION_NUMBER * 100
      equal_count = 0.0
    end

    documents
  end

  def match_documents
    ShingleSignature.select("DISTINCT ON (document_id) *").where(:token => shingle_signatures.map(&:token)).map(&:document).each do |document|
      document.match do |shingle_signature|
        tmp = shingle_signatures.select { |s| s.token == shingle_signature.token}.first
        tmp ? shingle_signature : nil
      end      
    end
  end

  def match &block
    start_shingle_signature = nil
    end_shingle_signature = nil
    number_global_shingle_signatures = 0
    prev_document_id = nil
    buffer_range = nil

    shingle_signatures.each do |shingle_signature|
      shingle_match = block ? yield(shingle_signature) : ShingleSignature.find_by_token(shingle_signature.token.to_s)

      if shingle_match
        shingle_signature.marked = true
        number_global_shingle_signatures += 1
      end
    end

    if number_global_shingle_signatures > 0
      @similarity =  (number_global_shingle_signatures * 100.0 / shingle_signatures.size).round(2)
    else
      @similarity = 0
    end
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
  #
  def create_i_match_signatures
    build_i_match_signatures
    i_match_signatures.map(&:save)
  end
    
  def shingle_signatures_to_cvs
  end

  def create_shingle_signatures
    tmp = {}
    build_shingle_signatures
    conn = ActiveRecord::Base.connection_pool.checkout
    raw = conn.raw_connection
    raw.exec("COPY shingle_signatures (token, position_start, position_end, document_id) FROM STDIN DELIMITERS ','")
    shingle_signatures.each do |shingle_signature|
      if !tmp.has_key?(shingle_signature.token) && ShingleSignature.find_by_token(shingle_signature.token).nil?
        raw.put_copy_data "#{shingle_signature.token}, #{shingle_signature.position_start}, #{shingle_signature.position_end}, #{shingle_signature.document_id}\n"
        tmp.merge! shingle_signature.token => true
      end
    end
    raw.put_copy_end
    while res = raw.get_result 
      # Говорят что важно
    end
    ActiveRecord::Base.connection_pool.checkin(conn)
  end

  private

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