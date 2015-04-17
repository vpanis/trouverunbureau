Deskspotting::Application.routes.draw do

  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks"}

  if Rails.env.development?
    mount MailPreview => 'mail_view'
  end

  root to: 'landing#index'
  resources :referrals, only: [:new]

  resources :venues, only: [:new, :create, :edit, :update, :show, :index] do
    member do
      get :details, to: 'venue_details#details'
      patch :details, to: 'venue_details#save_details'
      get :amenities, to: 'venue_amenities#amenities'
      patch :amenities, to: 'venue_amenities#save_amenities'
      get :photos
      get :spaces
      get :payment_methods
      get :new_space, to: "spaces#new"
      get :collection_account_info, to: "venue_collection_accounts#collection_account_info"
      patch :collection_account_info, to: "venue_collection_accounts#edit_collection_account"
      post :collection_account_info, to: "venue_collection_accounts#edit_collection_account"
    end
  end

  resources :users, only: [:show, :edit, :update] do
    member do
      get :account
      get :inbox
    end
    collection do
      post :login_as_organization, to: 'users#login_as_organization'
      delete :reset_organization, to: 'users#reset_organization'
    end
  end

  resources :organizations, only: [:index, :new, :edit, :update, :create, :show, :destroy]

  resources :spaces, only: [:edit, :update, :create, :destroy, :index] do
    member do
      get :inquiry, to: "space_booking_inquiry#inquiry"
      post :inquiry, to: "space_booking_inquiry#create_booking_inquiry"
    end
    collection do
      get :search_mobile
      get :wishlist
    end
  end

  resources :bookings, only: [:destroy, :create]  do
    member do
      get :client_review, to: "reviews#new_client_review"
      get :venue_review, to: "reviews#new_venue_review"
      post :client_review, to: "reviews#create_client_review"
      post :venue_review, to: "reviews#create_venue_review"
      get :receipt, to: "receipts#show"
    end
    collection do
      get :paid_bookings, to: "bookings#paid_bookings"
      get :venue_paid_bookings, to: "bookings#venue_paid_bookings"
    end
  end

  resources :payments, only: [:new, :create]

  get :about_us, to: 'landing#about_us'
  get :our_terms, to: 'landing#our_terms'
  get :how_it_works, to: 'landing#how_it_works'
  get :faq, to: 'landing#faq'
  get :contact, to: 'landing#contact'
  get :terms_of_service, to: 'landing#terms_of_service'
  get :privacy_policy, to: 'landing#privacy_policy'

  api_version(module: "api/v1", path: { value: 'api/v1' }) do
    resources :spaces, only: [:index]

    resources :users, only: [] do
      member do
        post :login_as_organization, to: 'users#login_as_organization'
        delete :reset_organization, to: 'users#reset_organization'
        get :reviews, to: 'reviews#user_reviews'
        get :inquiries, to: 'booking_inquiries#user_inquiries'
        get :inquiries_with_news, to: 'booking_inquiries#user_inquiries_with_news'
      end
    end

    resources :wishlist, only: [:index, :create, :destroy]

    resources :organizations, only:[] do
      resources :organization_users, only: [:create, :index, :destroy]
      member do
        get :reviews, to: 'reviews#organization_reviews'
        get :inquiries, to: 'booking_inquiries#organization_inquiries'
        get :inquiries_with_news, to: 'booking_inquiries#organization_inquiries_with_news'
      end
    end

    resources :venues, only: [] do
      member do
        get :reviews, to: 'reviews#venue_reviews'
      end
    end

    resources :inquiries, only: [] do
      member do
        put :last_seen_message, to: 'booking_inquiries#last_seen_message'
        put :edit, to: 'bookings#update_booking'
        post :messages, to: 'booking_inquiries#add_message'
        get :messages, to: 'booking_inquiries#messages'
        put :accept, to: 'bookings#accept'
        put :cancel, to: 'bookings#cancel'
        put :deny, to: 'bookings#deny'
      end
    end

    resources :venue_photos, only: [:create, :destroy]

    scope module: 'payments' do
      namespace :braintree do
        get :webhooks, to: 'hooks#verify_url'
        post :webhooks, to: 'hooks#notification'

        get :customer_nonce_token, to: 'payment#customer_nonce_token'
      end

      namespace :mangopay do
        get :new_card_info, to: 'credit_card#new_card_info'
        post :card_registration, to: 'credit_card#card_registration'
        put :save_credit_card, to: 'credit_card#save_credit_card'

        put :start_payment, to: 'payment#start_payment'
        get :payment_info, to: 'payment#payment_info'

        get :payin_succeeded, to: 'hooks#payin_succeeded'
        get :payin_failed, to: 'hooks#payin_failed'
        get :payin_succeeded, to: 'hooks#payout_succeeded'
        get :payin_failed, to: 'hooks#payout_failed'
      end
    end
  end # api/v1

end
