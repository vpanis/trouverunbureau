require 'resque/server'

Deskspotting::Application.routes.draw do

  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks"}
                                    # sessions: "users/sessions"}

  mount Resque::Server, at: "/resque"

  root to: 'landing#index'

  resources :venues, only: [:new, :create, :edit, :update, :show, :index] do
    member do
      get :search
      get :details
      patch :details, to: 'venues#save_details'
      get :amenities
      patch :amenities, to: 'venues#save_amenities'
      get :photos
      get :spaces
      get :new_space, to: "spaces#new"
    end
  end

  resources :users, only: [:show, :edit, :update] do
    member do
      get :account
    end
  end

  resources :spaces, only: [:edit, :update, :create] do
    collection do
      get :wishlist
    end
  end

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
        post :login_as_organization, to: 'users#login_as_organization'
        delete :reset_organization, to: 'users#reset_organization'
        get :reviews, to: 'reviews#user_reviews'
        get :inquiries, to: 'booking_inquiries#user_inquiries'
        get :inquiries_with_news, to: 'booking_inquiries#user_inquiries_with_news'
      end
    end

    resources :wishlist, only: [:index, :create, :destroy]

    resources :organizations do
      member do
        get :reviews, to: 'reviews#organization_reviews'
        get :inquiries, to: 'booking_inquiries#organization_inquiries'
        get :inquiries_with_news, to: 'booking_inquiries#organization_inquiries_with_news'
      end
    end

    resources :venues do
      member do
        get :reviews, to: 'reviews#venue_reviews'
      end
    end

    resources :inquiries do
      member do
        put :last_seen_message, to: 'booking_inquiries#last_seen_message'
        post :messages, to: 'booking_inquiries#add_message'
        get :messages, to: 'booking_inquiries#messages'
        put :accept, to: 'booking_inquiries#accept'
        put :cancel, to: 'booking_inquiries#cancel'
        put :deny, to: 'booking_inquiries#deny'
      end
    end

    resources :venue_photos, only: [:create, :destroy]
  end # api/v1

end
