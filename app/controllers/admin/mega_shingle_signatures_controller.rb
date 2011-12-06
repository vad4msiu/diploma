# -*- encoding : utf-8 -*-
class Admin::MegaShingleSignaturesController < Admin::MainController
  inherit_resources
  
  protected

  def collection
    @mega_shingle_signatures = end_of_association_chain.page(params[:page])
  end
end
