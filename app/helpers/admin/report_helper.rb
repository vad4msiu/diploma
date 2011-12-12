# -*- encoding : utf-8 -*-
module Admin::ReportHelper
  def paint document
    result = ''
    document.paint_sort
    current_position = 0

    document.paint.each do |coloring|
      if coloring.position_start > current_position
        result << h(document.content[current_position...coloring.position_start])
        result << content_tag(:span, :style => "background-color:#{coloring.color}", :'data-shingle-signature-token' => coloring.token, :class => 'shingle-signature') do
          h(document.content[coloring.position_start...coloring.position_end])
        end
      else
        result << content_tag(:span, :style => "background-color:#{coloring.color}", :'data-shingle-signature-token' => coloring.token, :class => 'shingle-signature') do
          h(document.content[current_position...coloring.position_end])
        end        
      end

      current_position = coloring.position_end
    end
    
    if current_position < document.content.length
      result << h(document.content[current_position...document.content.length])
    end

    return result.html_safe
  end
end
