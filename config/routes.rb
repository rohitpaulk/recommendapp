Rails.application.routes.draw do
  root 'pages#home'

  namespace 'api' do
    resources :users do
      resources :friends, only: :index
      resources :movies, only: :index
      resources :android_apps, only: [:index, :create] do
        collection do
          delete '/' => 'android_apps#batch_delete'
        end
      end
    end
    resources :android_apps, only: [:index, :show]
  end



  get 'api/recommendations'           => 'api/recommendations#index'
  post 'api/recommendations'          => 'api/recommendations#create'
  get 'api/recommendations/:id'       => 'api/recommendations#show'
  put 'api/recommendations/:id'       => 'api/recommendations#update'

  # post 'api/users/upsert' => 'api#users_upsert', as: :users_upsert
  # post 'api/user/apps/upsert' => 'api#user_apps_upsert', as: :user_apps_upsert

  # post 'api/recommendations/create' => 'api#recommendations_create', as: :recommendations_create


  # get 'api/recommendations/list' => 'api#recommendations_list', as: :recommendations_list


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

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
