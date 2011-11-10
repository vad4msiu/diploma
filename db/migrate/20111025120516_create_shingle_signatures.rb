# -*- encoding : utf-8 -*-
class CreateShingleSignatures < ActiveRecord::Migration
  def change
    create_table :shingle_signatures do |t|
      t.string :token, :unique => true
      t.text :canonized_content
      t.text :content
      t.integer :position_start
      t.integer :position_end
      t.integer :document_id
    end
    
    add_index :shingle_signatures, :token, :unique => true
    add_index :shingle_signatures, :document_id
  end
end
