Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  root 'welcome#index'
  get 'demo' => 'api/v3/demos#show'
  get 'status' => 'status#show'
  
  namespace :api do
    get '/' => 'apis#show'
    resource :apis, only: [:show]
    resources :readers, only: [:show, :index]
    resources :writers, only: [:show, :index]
    resources :codelists, only: [:show, :index]
    namespace :v2 do
      get '/' => 'api#show'
      resource :options, only: [:show]
      resource :translator, only: [:show, :create]
      resource :demo, only: [:show]
    end
    namespace :v3 do
      get '/' => 'api#show'
      resource :options, only: [:show]
      resource :translator, only: [:show, :create]
      resource :demo, only: [:show]
    end
  end

  # You can have the root of your site routed with "root"
  # 	root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :product

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
