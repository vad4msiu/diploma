# -*- encoding : utf-8 -*-
class ApplicationController < ActionController::Base
  protect_from_forgery
  layout :layout_by_resource

  private 
  
  def layout_by_resource
    "sign" if controller_name == "sessions" and action_name == "new"
  end
end
