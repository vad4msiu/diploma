# -*- encoding : utf-8 -*-
class Admin::ShingleSignaturesController < Admin::MainController
  inherit_resources
  
  protected

  def collection
    @shingle_signatures = end_of_association_chain.page(params[:page])
  end
end
