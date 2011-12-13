# -*- encoding : utf-8 -*-
class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.float :similarity
      t.text :content_document
      t.text :content_report
      t.integer :user_id
      t.string :state

      t.timestamps
    end
  end
end
