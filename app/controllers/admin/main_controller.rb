# -*- encoding : utf-8 -*-
class Admin::MainController < ApplicationController
  before_filter :authenticate_user!
  layout "admin"

  def similarity_shingles
  end

  def check_similarity_shingles
    @document = Document.new :content => params[:content]
    @document.build_shingle_signatures
    @document.similarity_shingle_signatures!
  end

  def similarity_super_shingles
  end

  def check_similarity_super_shingles
    @document = Document.new :content => params[:content]
    @document.build_super_shingle_signatures
    @documents = @document.similarity_super_shingle_signatures
  end
  
  
  def similarity_i_match
  end

  def check_similarity_i_match
    @document = Document.new :content => params[:content]
    @document.build_i_match_signatures
    @documents = Document.joins(:i_match_signatures).where("i_match_signatures.token = ?", @document.i_match_signatures.first)
  end  
  
  def similarity_sim_hash
  end

  def check_similarity_sim_hash
    @document = Document.new :content => params[:content]
    @document.build_min_hash_signatures
    @documents = @document.similarity_min_hash_signatures
  end  
end
