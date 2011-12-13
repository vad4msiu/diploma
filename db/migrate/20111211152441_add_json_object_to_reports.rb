# -*- encoding : utf-8 -*-
class AddJsonObjectToReports < ActiveRecord::Migration
  def change
    add_column :reports, :serialized_object, :text
  end
end
