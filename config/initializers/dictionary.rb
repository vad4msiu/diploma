# -*- encoding : utf-8 -*-

DICTIONARY = Word.where(:idf => 0..10).map(&:term).to_set

# module Dictionary
#   MIN_IDF = 0
#   MAX_IDF = 10
#   module_function
# 
#   def update text
#     number_documents = Document.count.to_f
#     text.split(/[^А-Яа-яA-Za-z]+/).uniq.each do |term|
#       word = Word.find_by_term(term)
#       if word
#         word.update_attribute :number_documents_found, (word.number_documents_found + 1)
#       else
#         Word.create(:term => term, :number_documents_found => 1)
#       end
#     end
#     
#     Word.all.each do |word|
#       word.update_attribute :idf, idf(number_documents, word.number_documents_found)
#     end
#   end
# 
#   def idf number_documents, number_documents_found
#     Math.log2(number_documents / number_documents_found)
#   end
# end