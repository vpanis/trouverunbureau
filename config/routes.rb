Deskspotting::Application.routes.draw do

  devise_for :users, controllers: { :omniauth_callbacks => "users/omniauth_callbacks" }

  root to: 'landing#index'

  api_version(module: "api/v1", path: { value: 'api/v1' }) do
    resources :users do
        member do
          get :reviews, to: 'reviews#client_reviews'
          get :wishlist, to: 'wishlist#wishlist'
        end
    end

    resources :venues do
        member do
          get :reviews, to: 'reviews#venue_reviews'
        end
    end
  end # api/v1
end
