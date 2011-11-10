# -*- encoding : utf-8 -*-
class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.text :content
      t.text :content_after_check, :default => ""
      t.float :similarity, :default => nil

      t.timestamps
    end
  end
end
