# -*- encoding : utf-8 -*-
module Admin::MainHelper
  def match_highlight document
    result = ''
    position_start = 0
    position_end = 0
    index = 0

    while index < (document.shingle_signatures.size - 1)
      shingle_signature = document.shingle_signatures[index]
      shingle_signature_next = document.shingle_signatures[index + 1]
      position_start = shingle_signature.position_start
      position_end = shingle_signature_next.position_start

      if shingle_signature.marked
        document_id = ShingleSignature.find_by_token(shingle_signature.token).document.id
        result << content_tag(:span, :'data-document-id' => document_id, :style => "background-color:#{ColorForDocument.get(document_id)}", :'data-shingle-signature-token' => shingle_signature.token, :class => 'shingle-signature') do
          h(document.content[position_start...position_end])
        end
      else
        result << h(document.content[position_start...position_end])
      end      
      index += 1
    end
    
    shingle_signature = document.shingle_signatures[index]
    position_start = position_end
    position_end = shingle_signature.position_end
    
    if shingle_signature.marked
      document_id = ShingleSignature.find_by_token(shingle_signature.token).document.id
      result << content_tag(:span, :'data-document-id' => document_id, :style => "background-color:#{ColorForDocument.get(document_id)}", :'data-shingle-signature-token' => shingle_signature.token, :class => 'shingle-signature') do
        h(document.content[position_start...position_end])
      end      
    else
      result << h(document.content[position_start...position_end])
    end          

    return result.html_safe
  end

  def match_highlight_documents match_documents
    result = ''

    match_documents.each do |document|
      result << content_tag(:div, :id => "document-#{document.id}", :class => 'document hide') do        
        content_tag(:h3) do
          "Document id: #{document.id}, #{"Source:" unless document.source.blank?} #{document.source}"
        end << match_highlight(document)        
      end
    end

    return result.html_safe
  end
end
