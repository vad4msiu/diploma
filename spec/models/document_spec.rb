# encoding: UTF-8

require 'spec_helper'

describe Document do
  it "#similar_shingle_signatures должен найти совпавшие шинглы" do
    document_1 = FactoryGirl.create(:document, :content => "Алгоритм построен на той идее, что в реальном мире сортируемый массив данных часто содержат в себе упорядоченные")
    document_2 = FactoryGirl.create(:document, :content => "Это и вправду часто так. На таких данных Timsort рвёт в клочья все остальные алгоритмы")
    document_3 = FactoryGirl.build(:document, :content => "Это и вправду часто так. На таких данных Timsort рвёт в клочья все остальные алгоритмы. Алгоритм построен на той идее, что в реальном мире сортируемый массив данных часто содержат в себе упорядоченные")

    document_3.matched_shingle_signatures.map(&:token).should include *(document_1.shingle_signatures.map(&:token) + document_2.shingle_signatures.map(&:token))
  end
end