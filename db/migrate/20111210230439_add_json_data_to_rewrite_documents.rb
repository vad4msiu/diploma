# -*- encoding : utf-8 -*-
class AddJsonDataToRewriteDocuments < ActiveRecord::Migration
  def change
    add_column :rewrite_documents, :json_data, :text
  end
end
