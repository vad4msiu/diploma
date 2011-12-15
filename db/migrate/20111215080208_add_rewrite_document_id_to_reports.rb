class AddRewriteDocumentIdToReports < ActiveRecord::Migration
  def change
    add_column :reports, :rewrite_document_id, :integer
  end
end
