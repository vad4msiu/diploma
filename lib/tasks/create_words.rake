# encoding: UTF-8

namespace :words do
  desc "Составление словря для I-Match"
  task :"re-create" => :environment do
    global_words = {}
    Document.all.each do |document|
      current_words = document.content.split(/[^А-ЯЁа-яё]+/).map{|w| Unicode::downcase(w)}.to_set
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
  end
end