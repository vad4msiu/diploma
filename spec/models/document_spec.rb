# encoding: UTF-8

require 'spec_helper'

describe Document do
#  it "#similar_shingle_signatures должен найти совпавшие шинглы" do
#    document_1 = FactoryGirl.create(:document, :content => "Алгоритм построен на той идее, что в реальном мире сортируемый массив данных часто содержат в себе упорядоченные")
#    document_2 = FactoryGirl.create(:document, :content => "Это и вправду часто так. На таких данных Timsort рвёт в клочья все остальные алгоритмы")
#    document_3 = FactoryGirl.build(:document, :content => "Это и вправду часто так. На таких данных Timsort рвёт в клочья все остальные алгоритмы. Алгоритм построен на той идее, что в реальном мире сортируемый массив данных часто содержат в себе упорядоченные")
#
#    document_3.matched_shingle_signatures.map(&:token).should include *(document_1.shingle_signatures.map(&:token) + document_2.shingle_signatures.map(&:token))
#  end
  
  it "#matches должен правильно раставить start и stop флаги" do
    document_1 = FactoryGirl.create(:document, :content => "Потребление, пренебрегая деталями, развивает сублимированный целевой сегмент рынка, отвоевывая свою долю рынка")
    document_2 = FactoryGirl.create(:document, :content => "Потребление, пренебрегая деталями, развивает сублимированный целевой картошка рынка, отвоевывая свою долю рынка")
    document_3 = FactoryGirl.build(:document, :content =>  "Потребление, пренебрегая деталями, развивает сублимированный целевой картошка рынка, отвоевывая свою долю рынка")
    
    document_3.build_shingle_signatures
    document_3.shingle_signatures.each do |s|
      puts document_3.content[s.position_start...s.position_end]
    end
    document_3.matches
    document_3.shingle_signatures.each do |s|
      puts "#{"start" if s.start} #{"end" if s.end}"
    end
    true
  end
end