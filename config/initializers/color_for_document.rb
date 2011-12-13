# -*- encoding : utf-8 -*-
class ColorForDocument
  # @@background_colors = ['#8181F7', '#81BEF7', '#81F7F3', '#81F7BE', '#81F781', '#BEF781', '#F3F781', '#F7BE81', '#F78181', '#F781BE', '#F781F3', '#BE81F7', '#3104B4', '#045FB4', '#04B486', '#AEB404', '#B18904', '#B45F04']
  @@background_colors = ['#F781BE']
  @@global_colors = {}

  def self.get id
    r, g, b = 100, 255, 255
    background_color = "rgb(#{(r + rand * 20).to_i}, #{(g - rand * 100).to_i}, #{(b - rand * 100).to_i})"
    @@global_colors.merge!(id => background_color) unless @@global_colors.has_key?(id)
    Rails.logger.debug { "global_colors: #{@@global_colors.inspect}" }
    @@global_colors[id]
  end

  def self.reset
    @@global_colors = {}
  end
end
