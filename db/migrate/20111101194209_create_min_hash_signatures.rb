class CreateMinHashSignatures < ActiveRecord::Migration
  def change
    create_table :min_hash_signatures do |t|
      t.string :token
      t.integer :document_id

      t.timestamps
    end
    
    add_index :min_hash_signatures, :document_id
  end
end
