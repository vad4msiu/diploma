# -*- encoding : utf-8 -*-
class Admin::MainController < ApplicationController
  before_filter :authenticate_user!
  layout "admin"

  def index

  end

  def check_similarity
    @document = Document.new :content => params[:content]
    case params[:type]
    when 'shingle'
      @document.build_shingle_signatures
      @document.similarity_shingle_signatures
      render 'admin/main/types/shingle'
    when 'super-shingle'
      @document.build_shingle_signatures
      @document.build_min_hash_signatures
      @document.build_super_shingle_signatures
      @documents = @document.similarity_super_shingle_signatures
      render 'admin/main/types/default'
    when 'mega-shingle'
      @document.build_shingle_signatures
      @document.build_min_hash_signatures
      @document.build_super_shingle_signatures
      @document.build_mega_shingle_signatures
      @documents = @document.similarity_mega_shingle_signatures
      render 'admin/main/types/default'
    when 'min-hash'
      @document.build_shingle_signatures
      @document.build_min_hash_signatures
      @documents = @document.similarity_min_hash_signatures
      render 'admin/main/types/default'
    when 'i-match'
      @document = Document.new :content => params[:content]
      @document.build_i_match_signatures
      @documents = @document.similarity_i_match_signatures
      render 'admin/main/types/default'
    end
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
