class RemoveContentDocumentAndContentReportFromReport < ActiveRecord::Migration
  def change
    remove_column :reports, :content_document
    remove_column :reports, :content_report
  end
end
