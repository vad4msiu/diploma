# -*- encoding : utf-8 -*-
class Admin::UsersController < Admin::MainController
  inherit_resources
  
  protected

  def collection
    @users = end_of_association_chain.page(params[:page])
  end    
end
