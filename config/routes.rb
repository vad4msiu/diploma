# -*- encoding : utf-8 -*-
Diploma::Application.routes.draw do
  
  devise_for :users, :skip => :registrations

  root :to => "admin/main#index"

  namespace :admin do
    post 'check_similarity' => "main#check_similarity"
    # get 'similarity_shingles' => "main#similarity_shingles"
    # post 'check_similarity_shingles' => "main#check_similarity_shingles"
    # 
    # get 'similarity_super_shingles' => "main#similarity_super_shingles"
    # post 'check_similarity_super_shingles' => "main#check_similarity_super_shingles"
    # 
    # get 'similarity_mega_shingles' => "main#similarity_mega_shingles"
    # post 'check_similarity_mega_shingles' => "main#check_similarity_mega_shingles"    
    # 
    # get 'similarity_min_hash' => "main#similarity_min_hash"
    # post 'check_similarity_min_hash' => "main#check_similarity_min_hash"    
    # 
    # get 'similarity_i_match' => "main#similarity_i_match"
    # post 'check_similarity_i_match' => "main#check_similarity_i_match"
    # 
    resources :documents do
      resources :shingle_signatures
    end
    resources :i_match_signatures
    resources :shingle_signatures
    resources :super_shingle_signatures
    resources :mega_shingle_signatures
    resources :min_hash_signatures
    resources :words
  end
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
