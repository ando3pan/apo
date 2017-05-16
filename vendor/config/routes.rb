Rails.application.routes.draw do
  devise_for :users, :controllers => { :registrations => "registration", :sessions => "session" }

  root 'page#home'

  match '/admin',               to: 'page#admin',         via: [:get],          as: 'admin'
  match '/admin/approve',       to: 'page#approve',       via: [:get, :post],   as: 'approve'
  match '/admin/settings',      to: 'page#settings',      via: [:get, :post],          as: 'settings'
  match '/calendar',            to: 'page#calendar',      via: [:get],          as: 'calendar'
  match '/events',              to: 'page#events',        via: [:get],          as: 'events'
  match '/events_feed',         to: 'event#events_feed',  via: [:get],          as: 'event_json'

#  match '/events/autocomplete_fullname_name',
#          to: 'event#autocomplete_fullname_name',         via: [:get],  as:
#         'autocomplete'
  resources :event, only: [:autocomplete_user_displayname] do
    get :autocomplete_user_displayname, on: :collection
  end

  match '/info',                to: 'page#info',          via: [:get],          as: 'info'
  match '/announcements',       to: 'page#announcements', via: [:get],          as: 'announcements'
  match '/appreciations',       to: 'page#appreciations', via: [:get],          as: 'appreciations'

  match '/event/new',           to: 'event#new',          via: [:get, :post],   as: 'new_event'
  match '/event/signup',        to: 'event#signup',       via: [:post]
  match '/event/chairsheet',    to: 'event#chairsheet',   via: [:post]
  match '/event/cancel',        to: 'event#cancel',       via: [:post]
  match '/event/:id',           to: 'event#show',         via: [:get],          as: 'event'

  match '/meeting/:id',         to: 'event#meeting',      via: [:get],          as: 'meeting'
  match '/event/:id/chair',     to: 'event#chair',        via: [:get],          as: 'event_chair'
  match '/event/:id/delete',    to: 'event#destroy',      via: [:delete],       as: 'destroy_event'
  match '/users',               to: 'user#all',           via: [:get],          as: 'users'
  match '/user/:id',            to: 'user#show',          via: [:get],          as: 'user'
  match '/user/:id/update',     to: 'user#update',        via: [:get, :patch],  as: 'update_user'
  match '/user/:id/greensheet', to: 'user#greensheet',    via: [:get, :post, :patch],  as: 'greensheet'

  match '/forum',               to: 'forum#show',         via: [:get],          as: 'forum'
  match '/forum/:id',           to: 'forum#destroy_forum',via: [:delete],       as: 'destroy_forum'
  match '/forum/:id/edit',      to: 'forum#edit_forum',   via: [:get, :patch],  as: 'edit_forum'
  match '/forum/new',           to: 'forum#new',          via: [:get, :post],   as: 'new_forum'

  match '/forum/:id',           to: 'forum#topic',        via: [:get],          as: 'topic'
  match '/forum/:id/new',       to: 'forum#new_topic',    via: [:get, :post],   as: 'new_topic'
  match '/topic/:id/edit',      to: 'forum#edit_topic',   via: [:get, :patch],  as: 'edit_topic'
  match '/topic/:id',           to: 'forum#destroy_topic',via: [:delete],       as: 'destroy_topic'

  match '/topic/:id',           to: 'forum#post',         via: [:get, :post],   as: 'post'
  match '/post/:id/edit',       to: 'forum#edit_post',    via: [:get, :patch],  as: 'edit_post'
  match '/post/:id',            to: 'forum#destroy_post', via: [:delete],       as: 'destroy_post'

  match '/dc',                  to: 'page#dancecomp',     via: [:get]     

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
