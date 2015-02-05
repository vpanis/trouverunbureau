Deskspotting::Application.routes.draw do

  devise_for :users, controllers: { :omniauth_callbacks => "users/omniauth_callbacks" }

  root to: 'landing#index'

  resources :venues do
      member do
        get :reviews, to: 'api/reviews#reviews'
      end
  end

end
