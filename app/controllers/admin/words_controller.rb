# -*- encoding : utf-8 -*-
class Admin::WordsController < Admin::MainController
  inherit_resources
  
  protected

  def collection
    @words = end_of_association_chain.order("number_documents_found DESC").page(params[:page])
  end
end
