Deskspotting::Application.routes.draw do
  resources :session, only: [] do
    collection do
      get :login
    end

  end

end
