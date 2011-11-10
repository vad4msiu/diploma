class CreateMegaShingleSignatures < ActiveRecord::Migration
  def change
    create_table :mega_shingle_signatures do |t|
      t.string :token
      t.integer :document_id
      
      t.timestamps
    end
    
    add_index :mega_shingle_signatures, :document_id
  end
end
