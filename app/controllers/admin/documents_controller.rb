# -*- encoding : utf-8 -*-
class Admin::DocumentsController < Admin::MainController
  inherit_resources
  
  protected

  def collection
    @documents = end_of_association_chain.page(params[:page])
  end
end
