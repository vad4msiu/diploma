# -*- encoding : utf-8 -*-
class AddAlgorithmToReports < ActiveRecord::Migration
  def change
    add_column :reports, :algorithm, :string
  end
end
