# -*- encoding : utf-8 -*-
class Admin::SuperShingleSignaturesController < Admin::MainController
  inherit_resources
  
  protected

  def collection
    @super_shingle_signatures = end_of_association_chain.page(params[:page])
  end
end
