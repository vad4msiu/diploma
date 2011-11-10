class CreateSuperShingleSignatures < ActiveRecord::Migration
  def change
    create_table :super_shingle_signatures do |t|
      t.string :token
      t.integer :document_id

      t.timestamps
    end

    add_index :super_shingle_signatures, :document_id
  end
end
