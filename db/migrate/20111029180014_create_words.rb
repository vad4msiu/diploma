# -*- encoding : utf-8 -*-
class CreateWords < ActiveRecord::Migration
  def change
    create_table :words do |t|
      t.string :term
      t.integer :number_documents_found
      t.float :idf
    end
    
    add_index :words, :term
    add_index :words, :idf
  end
end
