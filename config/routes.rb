require 'resque/server'

Deskspotting::Application.routes.draw do

  devise_for :users, controllers: { :omniauth_callbacks => "users/omniauth_callbacks" }

  mount Resque::Server, at: "/resque"

  root to: 'landing#index'

  resources :venues, only: [:show]

  api_version(module: "api/v1", path: { value: 'api/v1' }) do
    resources :users do
        member do
          get :reviews, to: 'reviews#client_reviews'
          get :wishlist, to: 'wishlist#wishlist'
          post :wishlist, to: 'wishlist#add_space_to_wishlist'
          delete :wishlist, to: 'wishlist#remove_space_from_wishlist'
        end
    end

    resources :venues do
        member do
          get :reviews, to: 'reviews#venue_reviews'
        end
    end
  end # api/v1

end
