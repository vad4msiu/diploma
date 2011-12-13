# -*- encoding : utf-8 -*-
# Что бы Marshal нашел классы
Document.class
ShingleSignature.class
Coloring.class
MinHashSignature.class
IMatchSignature.class
MegaShingleSignature.class
SuperShingleSignature.class
LongSentSignature.class

class Report < ActiveRecord::Base
  belongs_to :user
  belongs_to :document

  state_machine :state, :initial => :new do
    event :initial do
      transition any => :new
    end

    event :process do
      transition :new => :processed
    end

    event :complite do
      transition :processed => :complited
    end
  end

  def cancel_generate
    initial!
  end
  
  # TODO Сериализация это плохо!
  def serialized_object=(object)
    Report.benchmark("Report#serialized_object=") do 
      write_attribute :serialized_object, ActiveSupport::Base64.encode64(Marshal.dump(object))
    end
  end

  def serialized_object
    Report.benchmark("Report#serialized_object") do 
      Marshal.load(ActiveSupport::Base64.decode64(read_attribute :serialized_object))
    end
  end
  
  def generate_and_save options = {}
    generate options
    save!
  end
  
  def similarity
    (read_attribute :similarity).round(0)    
  end

  def generate options = {}
    process!
    @document = options[:document].present? ? options[:document] : Document.new(:content => options[:content])
    @document.search_from_web if options[:web] == true
    case algorithm
    when 'shingle'
      @document.build_shingle_signatures
      @document.similarity_shingle_signatures
    when 'super-shingle'
      @document.build_shingle_signatures
      @document.build_min_hash_signatures
      @document.build_super_shingle_signatures
      @document.similarity_super_shingle_signatures
    when 'mega-shingle'
      @document.build_shingle_signatures
      @document.build_min_hash_signatures
      @document.build_super_shingle_signatures
      @document.build_mega_shingle_signatures
      @document.similarity_mega_shingle_signatures
    when 'min-hash'
      @document.build_shingle_signatures
      @document.build_min_hash_signatures
      @document.similarity_min_hash_signatures
    when 'i-match'
      @document.build_i_match_signatures
      @document.similarity_i_match_signatures
    when 'long-sent'
      @document.build_long_sent_signatures
      @document.similarity_long_sent_signatures
    end
    self.similarity = @document.similarity
    self.serialized_object = @document
    complite!   
  end
end
