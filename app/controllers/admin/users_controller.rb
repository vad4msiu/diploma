# -*- encoding : utf-8 -*-
class Admin::UsersController < Admin::MainController
  inherit_resources
  
  def create
    @user = User.new params[:user]
    
    if params[:role] == "admin"
      @user.role = :admin
    else 
      @user.role = :user
    end
    
    super
  end
  
  protected

  def collection
    @users = end_of_association_chain.page(params[:page])
  end    
end
