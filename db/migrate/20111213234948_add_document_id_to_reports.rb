class AddDocumentIdToReports < ActiveRecord::Migration
  def change
    add_column :reports, :document_id, :integer
  end
end
