# -*- encoding : utf-8 -*-
class ShingleSignature < ActiveRecord::Base
  SHNINGLE_LENGTH = 16
  belongs_to :document
  
  validates :token, :presence => true, :uniqueness => true
  validates :position_start, :presence => true, :numericality => true
  validates :position_end, :presence => true, :numericality => true
  validates :document_id, :presence => true
  
  def range
    self.position_start...self.position_end
  end
  
  def cut_content
    self.document.content[range]
  end
end
