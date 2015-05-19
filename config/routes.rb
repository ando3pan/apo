Rails.application.routes.draw do
  devise_for :users, :controllers => { :registrations => "registration", :sessions => "session" }

  root 'page#home'

  match '/admin',           to: 'page#admin',         via: [:get],          as: 'admin'
  match '/calendar',        to: 'page#calendar',      via: [:get],          as: 'calendar'
  match '/events',          to: 'page#events',        via: [:get],          as: 'events'
  match '/events_feed',     to: 'event#events_feed',  via: [:get],          as: 'event_json'

  match '/event/new',       to: 'event#new',          via: [:get, :post],   as: 'new_event'
  match '/event/signup',    to: 'event#signup',       via: [:post]
  match '/event/chairsheet',to: 'event#chairsheet',   via: [:post]
  match '/event/cancel',    to: 'event#cancel',       via: [:post]
  match '/event/:id',       to: 'event#show',         via: [:get],          as: 'event'
  match '/event/:id/chair', to: 'event#chair',        via: [:get],          as: 'event_chair'
  match '/user/:id',        to: 'user#show',          via: [:get],          as: 'user'
  match '/user/:id/update', to: 'user#update',        via: [:get, :patch],  as: 'update_user'

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
