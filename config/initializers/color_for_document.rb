# -*- encoding : utf-8 -*-
class ColorForDocument
  @@background_colors = ['#8181F7', '#81BEF7', '#81F7F3', '#81F7BE', '#81F781', '#BEF781', '#F3F781', '#F7BE81', '#F78181', '#F781BE', '#F781F3', '#BE81F7', '#3104B4', '#045FB4', '#04B486', '#AEB404', '#B18904', '#B45F04']
  @@global_colors = {}
  
  def self.get id
    @@global_colors.merge!(id => @@background_colors.shift) unless @@global_colors.has_key?(id)      
    @@global_colors[id]
  end
  
  def self.reset
    @@global_colors = {}
  end
end
