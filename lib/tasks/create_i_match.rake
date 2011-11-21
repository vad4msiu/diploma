namespace :documents do
  desc "Create I-Match dictionary"
  task :"re-i-match" => :environment do
    global_words = {}
    Document.all.each do |document|
      document.i_match_signatures.destroy_all
      current_words = document.content.split(/[^[:word:]]+/).to_set
      current_words.each do |word|
        if global_words.has_key?(word)
          global_words[word] += 1
        else
          global_words.merge!({ word => 1 })
        end
      end
    end

    document_count = Document.count.to_f
    Word.destroy_all
    global_words.each_pair do |word, number_documents_found|
      Word.create(:term => word, 
                  :number_documents_found => number_documents_found, 
                  :idf => Math.log2(document_count / number_documents_found))
    end
    
    Document.all.each do |document|
      document.create_i_match_signatures
    end
  end
end
