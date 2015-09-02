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
    resources :recommendations
    resources :search, only: [:index]
    resources :requests

    get 'home/movies' => 'home_page#movies'
    get 'home/movies/:category_id' => 'home_page#movies_show'
    get 'home/:android_apps' => 'home_page#android_apps'
    get 'home/android_apps/:category_id' => 'home_page#android_apps_show'
  end

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
