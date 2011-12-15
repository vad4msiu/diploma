class AddRewriteTypeToRewriteDocuments < ActiveRecord::Migration
  def change
    add_column :rewrite_documents, :rewrite_type, :string
  end
end
