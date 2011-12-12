class CreateRewriteDocuments < ActiveRecord::Migration
  def change
    create_table :rewrite_documents do |t|
      t.text :content

      t.timestamps
    end
  end
end
