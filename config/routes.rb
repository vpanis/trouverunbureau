Deskspotting::Application.routes.draw do
  resources :session, only: [] do
    collection do
      get :login
      get :signup
      get :reset_password
    end

  end

end
