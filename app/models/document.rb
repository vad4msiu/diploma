# -*- encoding : utf-8 -*-
class Document < ActiveRecord::Base
  has_many :shingle_signatures, :dependent => :destroy
  has_many :i_match_signatures, :dependent => :destroy
  has_many :min_hash_signatures, :dependent => :destroy, :order => 'id'
  has_many :super_shingle_signatures, :dependent => :destroy
  has_many :mega_shingle_signatures, :dependent => :destroy

  validates :content, :presence => true

  after_create :create_signatures
  
  def create_signatures
    create_super_shingle_signatures
    create_shingle_signatures
    create_i_match_signatures
    create_min_hash_signatures
    update_dictionary
  end

  def update_dictionary
    Dictionary.update(self.content)
  end
  
  def build_super_shingle_signatures
    shingling = Resemblance::Shingling.new(
      self.content,
      :stop_words => Text::STOP_WORDS,
      :shingle_length => ShingleSignature::SHNINGLE_LENGTH
    )

    signatures = Resemblance::MinHash.new(shingling.shingles, :function_count => 84).signatures
    
    self.super_shingle_signatures.new(:token => Resemblance::Hashing.signature(signatures[0...14].join))
    self.super_shingle_signatures.new(:token => Resemblance::Hashing.signature(signatures[14...28].join))
    self.super_shingle_signatures.new(:token => Resemblance::Hashing.signature(signatures[28...42].join))
    self.super_shingle_signatures.new(:token => Resemblance::Hashing.signature(signatures[42...56].join))
    self.super_shingle_signatures.new(:token => Resemblance::Hashing.signature(signatures[56...70].join))
    self.super_shingle_signatures.new(:token => Resemblance::Hashing.signature(signatures[70...84].join))
  end

  def build_min_hash_signatures
    shingling = Resemblance::Shingling.new(
      self.content,
      :stop_words => Text::STOP_WORDS,
      :shingle_length => ShingleSignature::SHNINGLE_LENGTH
    )

    Resemblance::MinHash.new(shingling.shingles).signatures.map do |signature|
      self.min_hash_signatures.new(:token => signature)
    end
  end

  def build_shingle_signatures
    shingling = Resemblance::Shingling.new(
      self.content,
      :stop_words => Text::STOP_WORDS,
      :shingle_length => ShingleSignature::SHNINGLE_LENGTH
    )

    shingling.each_shingles do |shingle, position_start, position_end|
      self.shingle_signatures.new(
        :token => Digest::MD5.hexdigest(shingle),
        :position_start => position_start,
        :position_end => position_end
      )
    enda
  end

  def build_i_match_signatures
    current_words = self.content.split(/[^А-Яа-яA-Za-z]+/).to_set
    global_words = Word.where(:idf => Dictionary::MIN_IDF..Dictionary::MAX_IDF).map(&:term).to_set
    self.i_match_signatures.new(:token => Resemblance::Hashing.signature((current_words & global_words).to_a.sort.join(" ")))
  end
  
  def similarity_super_shingle_signatures
    Document.joins(:super_shingle_signatures).where(:"super_shingle_signatures.token" => super_shingle_signatures.map(&:token).map(&:to_s)).group(:"documents.id")
  end

  def similarity_min_hash_signatures
    equal_count = 0.0
    documents = Document.joins(:min_hash_signatures).where(:"min_hash_signatures.token" => min_hash_signatures.map(&:token).map(&:to_s)).group(:"documents.id")

    documents.each do |document|
      Resemblance::MinHash::FUNCTION_COUNT.times do |i|
        equal_count += 1 if min_hash_signatures[i].token.to_s == document.min_hash_signatures[i].token.to_s
      end
      document.similarity = equal_count / Resemblance::MinHash::FUNCTION_COUNT * 100
      equal_count = 0.0
    end

    documents
  end

  def similarity_shingle_signatures
    document_match = {}
    ranges_shingle_signatures_match = []
    prev_range_last = 0
    number_matched_shingle_signatures = 0
    buffer_range = shingle_signatures.first.position_start..shingle_signatures.first.position_end
    prev_docuemnt = self

    self.shingle_signatures.each do |shingle_signature|
      range = shingle_signature.position_start..shingle_signature.position_end
      if shingle_match = ShingleSignature.find_by_token(shingle_signature.token.to_s)
        number_matched_shingle_signatures += 1
        if tmp = (buffer_range | range)
          buffer_range = tmp
        else
          ranges_shingle_signatures_match << buffer_range
          buffer_range = range
        end
        prev_docuemnt = shingle_match.document
      end
    end

    ranges_shingle_signatures_match << buffer_range
    ranges_shingle_signatures_match.each do |range|
      self.content_after_check << self.content[prev_range_last...range.first]
      self.content_after_check << "<span class='highlight'>" << self.content[range] << "</span>"
      prev_range_last = range.last
    end

    if number_matched_shingle_signatures > 0
      self.similarity =  (number_matched_shingle_signatures * 100.0 / self.shingle_signatures.size).round(2)
    else
      self.similarity = 0
    end
  end

  # def check_similarity
  #   bufer = ""
  #   number_not_matched_shingle = 0
  #   shingle_match, prev_shingle_match = nil, nil, nil
  #   number_match, position_start_shingle_match, position_end_shingle_match, position_end_shingle = 0, 0, 0, 0
  #
  #   self.shingles.each do |shingle|
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
  #         self.content_after_check << "<span class='highlight' id='document-#{shingle_match.document.id}'>"
  #         # number_not_matched_shingle = 0
  #       end
  #     else
  #       number_not_matched_shingle += 1
  #     end
  #     # Если текущий шингл не найден а предыдущий был найден значит надо закрыть тег
  #     # self.content_after_check << "</span>" if (shingle_match.nil? && prev_shingle_match && number_not_matched_shingle > 3)
  #     # if number_not_matched_shingle > Shingle::SHNINGLE_LEGTH && prev_shingle_match
  #     #   self.content_after_check << "</span>"
  #     #   self.content_after_check << bufer
  #     #   bufer = ""
  #     #   number_not_matched_shingle = 0
  #     # end
  #     # # Если текущий и предыдущий шинглы найдены, но они относятся к разным документам надо закрыть тег и открыть сново
  #     # if prev_shingle_match && shingle_match && shingle_match.document.id != prev_shingle_match.document.id
  #     #   self.content_after_check << "</span>"
  #     #   self.content_after_check << "<span class='highlight' id='document-#{shingle_match.document.id}'>"
  #     # end
  #
  #     if shingle_match
  #       self.content_after_check << self.content[position_end_shingle...shingle.position_end]
  #     # else
  #     #   bufer << self.content[position_end_shingle...shingle.position_end]
  #     end
  #     # if number_not_matched_shingle >= Shingle::SHNINGLE_LEGTH
  #     #   self.content_after_check << bufer
  #     #   bufer = ""
  #     # end
  #     # Запоминаем найденный шингл и его позицию конца в тексте
  #     prev_shingle_match = shingle_match# if number_not_matched_shingle == 0
  #     position_end_shingle = shingle.position_end
  #   end
  #
  #   # Проверка если последний шингл найден а документ закончился надо закрыть тег
  #   self.content_after_check << "</span>" if shingle_match
  #
  #   self.similarity = number_match > 0 ? (number_match * 100.0 / self.shingles.size).round(2) : 0
  # end

  def create_super_shingle_signatures
    self.build_super_shingle_signatures
    self.super_shingle_signatures.map(&:save)
  end  

  def create_min_hash_signatures
    self.build_min_hash_signatures
    self.min_hash_signatures.map(&:save)
  end

  def create_i_match_signatures
    self.build_i_match_signatures
    self.i_match_signatures.map(&:save)
  end

  def create_shingle_signatures
    self.build_shingle_signatures
    self.shingle_signatures.map(&:save)
  end
end