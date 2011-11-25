class ColorForDocument
  @@background_colors = ["#FFE4C4", "#00BFFF", "#66CDAA", "#FFFF00", "#CD5C5C", "#EE82EE", "#EEE9BF"]
  @@global_colors = {}
  
  def self.get id
    @@global_colors.merge!(id => @@background_colors.shift) unless @@global_colors.has_key?(id)      
    @@global_colors[id]
  end
end