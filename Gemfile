source 'http://rubygems.org'

ruby '2.3.4'

gem 'rails', '~> 4.1.16'

gem 'google-webfonts-rails', '~>0.0.4'
gem 'font_assets'

# Use postgresql as the database for Active Record
gem 'pg', '~>0.18'

# To extract sensitive configuration
gem 'app_configuration', '~>0.0.3'

# Use unicorn as the app server
gem 'unicorn', '~>4.8.3'

# Api versions
gem 'versionist', '~>1.4.0'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.0.3'
gem 'less-rails', '~>2.5.0'
gem 'therubyracer', '~>0.12.1'
gem 'twitter-bootstrap-rails', '~>3.2.0'

# Use jquery as the JavaScript library
gem 'jquery-rails', '~>3.1.2'

gem 'loadjs', '~>0.0.6'

gem 'inherited_resources', '~>1.4.1'

# angularjs
gem 'angular-translate-rails'
gem 'angular-ui-bootstrap-rails'
gem 'angularjs-rails'

gem 'select2-rails'

gem 'fog', '~>1.36.0'
gem 'carrierwave', '~>0.11.2'

gem 'rmagick', require: false

gem 'turbolinks', '~>2.3.0'

gem 'jquery-turbolinks', '~>2.1.0'

gem 'jquery-inputmask-rails'

gem 'devise', '~>3.3.0'
gem 'omniauth-facebook'
gem 'devise-async', '~>0.9.0'

# SQL simplifier
gem 'squeel'

# Active Admin
gem 'activeadmin', github: 'activeadmin'
gem 'formtastic', '~>2.3.1'
gem 'ransack', '~>1.4.1'
gem 'polyamorous', '~>1.1.0'

# Enables Slim templates
gem 'slim-rails', '~>2.1.5'

# Sidekiq
gem 'sidekiq', '~> 4.0'
gem 'sidekiq-failures'
gem 'sidetiq', '0.7.0'

gem 'sinatra', '>= 1.3.0', require: nil

gem 'pundit', '~>0.3.0'

# Exceptions Report
gem 'airbrake', '~>3.1.14'

# Active Model Serializers for JSON api
gem 'active_model_serializers', '~>0.9.3'

gem 'will_paginate', '~>3.0.7'

# If required only for development, stage and production will EXPLODE
gem 'mail_view', '~> 2.0.4'

gem 'mail_form'

gem 'countries'

# Timezone from geonames
gem 'timezone'

# Payment Methods
gem 'braintree', '~>2.40.0'

# Sticking with 3.0.15 because of breaking changes of
# https://docs.mangopay.com/api-v2-01-overview/
gem 'mangopay', '3.0.15'

gem 'devise_invitable'

# integers in db, decimals in use
gem 'acts_as_decimal'

# Languages
gem 'language_list'
gem 'http_accept_language'

gem 'rollbar'
gem 'newrelic_rpm'

group :development do
  gem 'better_errors', '~>2.0.0'
  gem 'binding_of_caller', '~>0.7.2'
  gem 'spring', '~>1.1.3'
  gem 'meta_request'
  gem 'quiet_assets'

  # Livereload
  gem 'guard', '>= 2.2.2',       require: false
  gem 'guard-livereload',        require: false
  gem 'rack-livereload'
  gem 'rb-fsevent',              require: false

  # Lints
  gem 'rubocop', '~>0.26.1'
  gem 'font_assets'
end

group :debugging, :development, :test do
  gem 'pry'
  gem 'byebug'
  gem 'pry-byebug'
  gem 'pry-stack_explorer'
end

group :test, :development do
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'

  # Modify time in tests
  gem 'timecop', '~>0.7.1'

  # Cucumber with JS
  gem 'poltergeist'

  # Save and open page cucumber
  gem 'launchy'
end

group :test do
  # CodeClimate Reporter
  gem 'codeclimate-test-reporter', require: nil
  gem 'simplecov', require: false

  gem 'rspec-sidekiq'
  gem 'shoulda-callback-matchers', '~> 1.1.4'
  gem 'shoulda-matchers', '~> 3.1'
end

group :production do
  gem 'rails_12factor'
end

gem 'figaro', '~> 1.1', '>= 1.1.1'
gem 'intercom-rails'
gem 'meta-tags'
gem 'non-stupid-digest-assets'
gem 'mixpanel-ruby'
gem 'table_print'
gem 'awesome_print', '~> 1.8'
