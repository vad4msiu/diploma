# -*- encoding : utf-8 -*-
class CreateLongSentSignatures < ActiveRecord::Migration
  def change
    create_table :long_sent_signatures do |t|
      t.string :token
      t.integer :document_id

      t.timestamps
    end
  end
end
