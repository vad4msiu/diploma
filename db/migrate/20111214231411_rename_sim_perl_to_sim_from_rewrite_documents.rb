class RenameSimPerlToSimFromRewriteDocuments < ActiveRecord::Migration
  def change
    rename_column :rewrite_documents, :sim_perl, :sim
  end
end