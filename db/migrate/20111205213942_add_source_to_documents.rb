# -*- encoding : utf-8 -*-
class AddSourceToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :source, :text
  end
end
