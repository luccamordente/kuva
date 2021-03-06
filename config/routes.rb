Kuva::Application.routes.draw do


  namespace :admin do

    resources :orders do
      member do
        get :download
      end
      resources :photos, only: [:show] do
        get :download, on: :member
      end
    end

    resources :products
    resources :users, except: :destroy do
      get  :password       , on: :member
      post :update_password, on: :member
    end

    root to: "orders#index"
  end


  namespace :api do
    resources :orders, only: [:show] do
      get :closed  , on: :collection
      get :download, on: :member
    end
  end



  devise_for :users, controllers: { sessions: "sessions" }

  root to: redirect("/users/sign_in")


  scope :path_names => { :new => "novo", :edit => "alterar" } do
    resources :orders, only: [:index, :new, :create, :update], path: "pedidos" do
      post :close, on: :member
      post :cancel, on: :member

      resources :photos, only: [:create, :update] do
        post :check, on: :collection
      end

      resources :images, only: [:create]
    end
  end


  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', as: :purchase
  # This route can be invoked with purchase_url(id: product.id)

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
  #       get 'recent', on: :collection
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
  # root to: 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
