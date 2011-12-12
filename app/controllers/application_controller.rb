# -*- encoding : utf-8 -*-
class ApplicationController < ActionController::Base
  # ActiveRecord::Base.logger = nil
  protect_from_forgery
  layout :layout_by_resource
  before_filter :reset_color_for_document

  private

  def reset_color_for_document
    ColorForDocument.reset
  end

  def layout_by_resource
    "sign" if controller_name == "sessions" and action_name == "new"
  end
end
