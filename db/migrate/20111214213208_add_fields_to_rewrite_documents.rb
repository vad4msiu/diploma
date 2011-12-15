class AddFieldsToRewriteDocuments < ActiveRecord::Migration
  def change
    add_column :rewrite_documents, :duplicate, :boolean
    add_column :rewrite_documents, :sim_perl, :float
  end
end