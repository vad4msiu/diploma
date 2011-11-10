# -*- encoding : utf-8 -*-
class ShingleSignature < ActiveRecord::Base
  SHNINGLE_LENGTH = 5
  belongs_to :document
  
  validates :token, :presence => true, :uniqueness => true
  validates :position_start, :presence => true, :numericality => true
  validates :position_end, :presence => true, :numericality => true
  
  # def content
  #   self.document.content[self.position_start..self.position_end]
  # end
end
