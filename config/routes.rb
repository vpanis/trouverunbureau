require 'resque/server'

Deskspotting::Application.routes.draw do

  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks"}
                                    # sessions: "users/sessions"}

  mount Resque::Server, at: "/resque"

  root to: 'landing#index'

  resources :venues, only: [:edit, :update, :show]
  resources :users, only: [:show, :edit, :update]
  resources :spaces, only: [:edit, :update]
  resources :bookings, only: [:destroy]  do
    collection do
      get :paid_bookings, to: "bookings#paid_bookings"
      get :venue_paid_bookings, to: "bookings#venue_paid_bookings"
    end
  end

  api_version(module: "api/v1", path: { value: 'api/v1' }) do
    get :spaces, to: 'space#list'

    resources :users do
        member do
          get :wishlist, to: 'wishlist#wishlist'
          post :wishlist, to: 'wishlist#add_space_to_wishlist'
          delete :wishlist, to: 'wishlist#remove_space_from_wishlist'
          post :login_as_organization, to: 'users#login_as_organization'
          delete :reset_organization, to: 'users#reset_organization'
          get :reviews, to: 'reviews#user_reviews'
        end
    end

    resources :organizations do
      member do
        get :reviews, to: 'reviews#organization_reviews'
      end
    end

    resources :venues do
        member do
          get :reviews, to: 'reviews#venue_reviews'
        end
    end
  end # api/v1

end
