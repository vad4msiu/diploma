# -*- encoding : utf-8 -*-
class AddDocumentIdToRewriteDocuments < ActiveRecord::Migration
  def change
    add_column :rewrite_documents, :document_id, :integer
  end
end
