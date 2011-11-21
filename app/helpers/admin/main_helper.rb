# -*- encoding : utf-8 -*-
module Admin::MainHelper
  def highlight_document_similar_shingles document
    position_start, position_end = 0, 0
    prev_shingle_signature = nil
    buffer = ""
    count = 0
    
    document.shingle_signatures.each do |shingle_signature|
      similar_shingle_signature = ShingleSignatrue.find_by_token shingle_signature.token
      
      if similar_shingle_signature
        if prev_shingle_signature count < ShingleSignature::SHNINGLE_LENGTH
          position_start = shingle_signature.position_start
        else
          buffer << "<span class='highlight' id=#{prev_shingle_signature.document.id}>" << prev_shingle_signature.position_start...similar_shingle_signature.start << "</span>"
        end
        count += 1
        if count == ShingleSignature::SHNINGLE_LENGTH
          buffer << document.content[position_range]
          buffer << document.content[position_range.last...shingle_signature.position_start]
          count = 0
        end
      else
        
      end
      
    end
    
    document.similar_shingle_signatures.each do |similar_shingle_signature|
      Rails.logger.debug { "document: #{document.inspect}\n\nsimilar_shingle_signature: #{similar_shingle_signature.inspect}" }
      shingle_signature = (document.shingle_signatures.select { |shingle_signature| shingle_signature.token == similar_shingle_signature.token}).first
      buffer << document.content[position_start...shingle_signature.position_start]
      buffer << "<span class='highlight'>" << document.content[shingle_signature.range] << "</span>"
      position_start = shingle_signature.position_end
    end
    
    return raw(buffer)
  end
end
