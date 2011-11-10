# -*- encoding : utf-8 -*-
class Word < ActiveRecord::Base
  before_save :process_idf
  
  private 
  
  def process_idf
    Dictionary
  end
end
