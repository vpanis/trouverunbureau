Deskspotting::Application.routes.draw do

  devise_for :users, controllers: { :omniauth_callbacks => "users/omniauth_callbacks" }

  root to: 'landing#index'

  resources :users do
      member do
        get :reviews, to: 'api/reviews#client_reviews'
      end
  end

  resources :venues do
      member do
        get :reviews, to: 'api/reviews#venue_reviews'
      end
  end

end
