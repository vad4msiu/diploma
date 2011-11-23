# -*- encoding : utf-8 -*-
class Document < ActiveRecord::Base
  has_many :shingle_signatures, :dependent => :destroy, :order => 'id'
  has_many :i_match_signatures, :dependent => :destroy, :order => 'id'
  has_many :min_hash_signatures, :dependent => :destroy, :order => 'id'
  has_many :super_shingle_signatures, :dependent => :destroy, :order => 'id'
  has_many :mega_shingle_signatures, :dependent => :destroy, :order => 'id'

  validates :content, :presence => true

  after_create :create_signatures
  
  attr_accessor :similar_documents_after_check, :content_after_check, :similarity
  
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
  end

  def build_i_match_signatures
    current_words = content.split(/[^[:word:]]+/).to_set
    i_match_signatures.new(:token => Digest::MD5.hexdigest((current_words & Word.where(:idf => 2..4).map(&:term).to_set).to_a.sort.join))
  end

  def similarity_super_shingle_signatures
    Document.joins(:super_shingle_signatures).where(:"super_shingle_signatures.token" => super_shingle_signatures.map(&:token).map(&:to_s)).group(:"documents.id")
  end

  def similarity_i_match_signatures
    Document.joins(:i_match_signatures).where(:"i_match_signatures.token" => i_match_signatures.map(&:token).map(&:to_s)).group(:"documents.id")
  end  

  def similarity_mega_shingle_signatures
    Document.joins(:mega_shingle_signatures).where(:"mega_shingle_signatures.token" => mega_shingle_signatures.map(&:token).map(&:to_s)).group(:"documents.id")
  end
  
  def similarity_min_hash_signatures
    equal_count = 0.0
    documents = Document.joins(:min_hash_signatures).where(:"min_hash_signatures.token" => min_hash_signatures.map(&:token).map(&:to_s)).group(:"documents.id")
  
    documents.each do |document|
      MinWise::FUNCTION_NUMBER.times do |i|
        equal_count += 1 if min_hash_signatures[i].token.to_s == document.min_hash_signatures[i].token.to_s
      end
      document.similarity = equal_count / MinWise::FUNCTION_NUMBER * 100
      equal_count = 0.0
    end
  
    documents
  end
  
  def similar_shingle_signatures
    ShingleSignature.where(:token => shingle_signatures.map(&:token))
  end

  # Кромешный АД
  def similarity_shingle_signatures
    buffer_shingle_signatures = []
    ranges_shingle_signatures_match = []
    prev_range_last = 0
    number_matched_shingle_signatures = 0
    prev_document_id = nil
    similar_documents = []
    buffer_range = nil
    similar_shingle_signatures = {}
    shingle_match = nil
    
    shingle_signatures.each do |shingle_signature|
      range = shingle_signature.position_start..shingle_signature.position_end
      if shingle_match = ShingleSignature.find_by_token(shingle_signature.token.to_s)
        buffer_range ||= shingle_signature.range
        prev_document_id ||= shingle_match.document.id
        number_matched_shingle_signatures += 1

        if (tmp = (buffer_range | range)) && prev_document_id == shingle_match.document.id
          buffer_range = tmp
        else
          similar_documents << prev_document_id
          ranges_shingle_signatures_match << buffer_range          
          buffer_range = range
        end
        
        if similar_shingle_signatures.has_key?(shingle_match.document)
          similar_shingle_signatures[shingle_match.document] << shingle_match
        else
          similar_shingle_signatures.merge!({shingle_match.document => [shingle_match]})
        end
        prev_document_id = shingle_match.document.id
      end
    end
    
    similar_documents << shingle_match.document.id if shingle_match
    ranges_shingle_signatures_match << buffer_range if buffer_range
    @content_after_check = ''
    ranges_shingle_signatures_match.each do |range|
      # similar_shingle_signature = similar_shingle_signatures.shift
      @content_after_check << content[prev_range_last...range.first]
      @content_after_check << "<span class='highlight' id='#{similar_documents.shift}'>" << content[range] << "</span>"
      prev_range_last = range.last
    end

    if number_matched_shingle_signatures > 0
      @similarity =  (number_matched_shingle_signatures * 100.0 / shingle_signatures.size).round(2)
    else
      @similarity = 0
    end
    
    # Rails.logger.debug { "message #{similar_shingle_signatures.inspect}" }
    @similar_documents_after_check = ""
    range_not_include = nil
    range_include = nil
    similar_shingle_signatures.each_pair do |document, shingle_signatures|
      # document = Document.find document_id
      @similar_documents_after_check << "<div class='hide' id='document-#{document.id}'><h3>Document id: #{document.id}</h3>"
      
      ranges = []
      buffer_range = nil
      shingle_signatures.each do |shingle_signature|
        buffer_range ||= shingle_signature.range
        if tmp = (buffer_range | shingle_signature.range)
          buffer_range = tmp
        else
          ranges << buffer_range
          buffer_range = shingle_signature.range
        end
      end
      ranges << buffer_range
      Rails.logger.debug { "ranges #{ranges.inspect}" }
      prev_range_last = 0
      ranges.each do |range|
        @similar_documents_after_check << document.content[prev_range_last...range.first]
        @similar_documents_after_check <<  "<span class='highlight'>" << document.content[range] << "</span>"
        prev_range_last = range.last
      end
      @similar_documents_after_check << document.content[prev_range_last...document.content.length]
      @similar_documents_after_check << "</div>"
    end
    
    Rails.logger.debug { "#{self.similarity}" }
  end

  # def check_similarity
  #   bufer = ""
  #   number_not_matched_shingle = 0
  #   shingle_match, prev_shingle_match = nil, nil, nil
  #   number_match, position_start_shingle_match, position_end_shingle_match, position_end_shingle = 0, 0, 0, 0
  #
  #   shingles.each do |shingle|
  #     Rails.logger.debug { "message #{shingle.canonized_content}" }
  #     if shingle_match = Shingle.find_by_token(shingle.token)
  #       number_match += 1
  #       # if ((shingle_match.position_start - 50) > 0)
  #       #   position_start_shingle_match = shingle_match.position_start - 50
  #       # else
  #       #   position_start_shingle_match = 0
  #       # end
  #       #
  #       # if ((shingle_match.position_end + 50) <= shingle_match.document.content.length)
  #       #   position_end_shingle_match =  shingle_match.position_end + 50
  #       # else
  #       #   position_end_shingle_match = shingle_match.document.content.length
  #       # end
  #
  #       # Если перед этим не было совпадений шинглов вставляем начало тега
  #       if !prev_shingle_match && number_not_matched_shingle < Shingle::SHNINGLE_LEGTH
  #         content_after_check << "<span class='highlight' id='document-#{shingle_match.document.id}'>"
  #         # number_not_matched_shingle = 0
  #       end
  #     else
  #       number_not_matched_shingle += 1
  #     end
  #     # Если текущий шингл не найден а предыдущий был найден значит надо закрыть тег
  #     # content_after_check << "</span>" if (shingle_match.nil? && prev_shingle_match && number_not_matched_shingle > 3)
  #     # if number_not_matched_shingle > Shingle::SHNINGLE_LEGTH && prev_shingle_match
  #     #   content_after_check << "</span>"
  #     #   content_after_check << bufer
  #     #   bufer = ""
  #     #   number_not_matched_shingle = 0
  #     # end
  #     # # Если текущий и предыдущий шинглы найдены, но они относятся к разным документам надо закрыть тег и открыть сново
  #     # if prev_shingle_match && shingle_match && shingle_match.document.id != prev_shingle_match.document.id
  #     #   content_after_check << "</span>"
  #     #   content_after_check << "<span class='highlight' id='document-#{shingle_match.document.id}'>"
  #     # end
  #
  #     if shingle_match
  #       content_after_check << content[position_end_shingle...shingle.position_end]
  #     # else
  #     #   bufer << content[position_end_shingle...shingle.position_end]
  #     end
  #     # if number_not_matched_shingle >= Shingle::SHNINGLE_LEGTH
  #     #   content_after_check << bufer
  #     #   bufer = ""
  #     # end
  #     # Запоминаем найденный шингл и его позицию конца в тексте
  #     prev_shingle_match = shingle_match# if number_not_matched_shingle == 0
  #     position_end_shingle = shingle.position_end
  #   end
  #
  #   # Проверка если последний шингл найден а документ закончился надо закрыть тег
  #   content_after_check << "</span>" if shingle_match
  #
  #   similarity = number_match > 0 ? (number_match * 100.0 / shingles.size).round(2) : 0
  # end

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

  def create_shingle_signatures
    build_shingle_signatures
    shingle_signatures.map(&:save)
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