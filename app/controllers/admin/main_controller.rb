# -*- encoding : utf-8 -*-
class Admin::MainController < ApplicationController
  before_filter :authenticate_user!
  layout "admin"

  def similarity_shingles
  end

  def check_similarity_shingles
    @document = Document.new :content => params[:content]
    @document.build_shingle_signatures
    @document.similarity_shingle_signatures
  end

  def similarity_super_shingles
  end

  def check_similarity_super_shingles
    @document = Document.new :content => params[:content]
    @document.build_shingle_signatures
    @document.build_min_hash_signatures
    @document.build_super_shingle_signatures
    @documents = @document.similarity_super_shingle_signatures
  end
  
  def similarity_mega_shingles
  end

  def check_similarity_mega_shingles
    @document = Document.new :content => params[:content]
    @document.build_shingle_signatures
    @document.build_min_hash_signatures
    @document.build_super_shingle_signatures
    @document.build_mega_shingle_signatures
    @documents = @document.similarity_mega_shingle_signatures
  end
  

  def similarity_i_match
  end

  def check_similarity_i_match
    @document = Document.new :content => params[:content]
    @document.build_i_match_signatures
    @documents = Document.joins(:i_match_signatures).where("i_match_signatures.token = ?", @document.i_match_signatures.first)
  end

  def similarity_min_hash
  end

  def check_similarity_min_hash
    @document = Document.new :content => params[:content]
    @document.build_shingle_signatures
    @document.build_min_hash_signatures
    @documents = @document.similarity_min_hash_signatures
  end
end
