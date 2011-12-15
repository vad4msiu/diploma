class AddSimTypeToRewriteDocuments < ActiveRecord::Migration
  def change
    add_column :rewrite_documents, :sim_type, :string
  end
end
