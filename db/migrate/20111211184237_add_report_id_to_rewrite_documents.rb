# -*- encoding : utf-8 -*-
class AddReportIdToRewriteDocuments < ActiveRecord::Migration
  def change
    add_column :rewrite_documents, :report_id, :integer
  end
end
