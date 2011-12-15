class RemoveReportIdFromRewriteDocumets < ActiveRecord::Migration
  def change
    remove_column :rewrite_documents, :report_id
  end
end
