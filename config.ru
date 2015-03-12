# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
run Rails.application


# Sidekiq password
require 'sidekiq'

require 'sidekiq/web'

sidekiq = AppConfiguration.for(:sidekiq)

map '/sidekiq' do
  use Rack::Auth::Basic, "Protected Area" do |username, password|
    username == sidekiq.user && password == sidekiq.password
  end

  run Sidekiq::Web
end
