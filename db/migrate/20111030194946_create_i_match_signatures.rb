class CreateIMatchSignatures < ActiveRecord::Migration
  def change
    create_table :i_match_signatures do |t|
      t.string :token
      t.integer :document_id

      t.timestamps
    end
  end
end
