# -*- encoding : utf-8 -*-
class Admin::IMatchSignaturesController < Admin::MainController
  inherit_resources
  
  protected

  def collection
    @i_match_signatures = end_of_association_chain.page(params[:page])
  end
end
