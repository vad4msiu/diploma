# -*- encoding : utf-8 -*-
class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.text :content

      t.timestamps
    end
  end
end
