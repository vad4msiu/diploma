# -*- encoding : utf-8 -*-
class Admin::MinHashSignaturesController < Admin::MainController
  inherit_resources
  
  protected

  def collection
    @min_hash_signatures = end_of_association_chain.page(params[:page])
  end
end
