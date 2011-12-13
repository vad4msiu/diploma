# -*- encoding : utf-8 -*-
class Coloring
  attr_reader :position_start, :position_end, :color, :token
  
  def initialize(options = {})
    @position_start = options[:position_start]
    @position_end = options[:position_end]
    @color = options[:color]
    @token = options[:token]
  end  
end
