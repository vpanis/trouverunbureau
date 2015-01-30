source 'http://rubygems.org'

ruby '2.1.5'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.8'

gem 'google-webfonts-rails', '~>0.0.4'

# Use postgresql as the database for Active Record
gem 'pg', '~>0.17.1'

# To extract sensitive configuration
gem 'app_configuration' , '~>0.0.3'

# Use unicorn as the app server
gem 'unicorn', '~>4.8.3'

# Api versions
gem 'versionist', '~>1.4.0'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.0.3'
gem 'less-rails', '~>2.5.0'
gem 'therubyracer', '~>0.12.1'
gem 'twitter-bootstrap-rails', '~>3.2.0'

# Use jquery as the JavaScript library
gem 'jquery-rails', '~>3.1.2'

gem 'loadjs', '~>0.0.6'

#angularjs
gem 'angularjs-rails'

gem 'inherited_resources' , '~>1.4.1'

gem 'carrierwave', '~>0.10.0'

gem 'rmagick', '~>2.13.4'

gem 'turbolinks' , '~>2.3.0'

gem 'jquery-turbolinks', '~>2.1.0'

gem 'devise', '~>3.3.0'
gem 'omniauth-facebook', '~>2.0.0'
gem 'devise-async', '~>0.9.0'

# SQL simplifier
gem 'squeel', '~>1.2.2'

# CodeClimate Reporter
gem 'codeclimate-test-reporter', group: :test, require: nil
gem 'simplecov', require: false, group: :test

# Active Admin
gem 'activeadmin', github: 'activeadmin'
gem 'formtastic' , '~>2.3.1'
gem 'ransack', '~>1.4.1'
gem 'polyamorous', '~>1.1.0'

# Enables Slim templates
gem 'slim-rails', '~>2.1.5'

# Sidekiq
# gem 'sidekiq', '~>3.2.5'
gem 'sinatra', '>= 1.3.0', require: nil

gem 'pundit', '~>0.3.0'

# Exceptions Report
gem 'airbrake', '~>3.1.14'

# Active Model Serializers for JSON api
gem 'active_model_serializers', '~>0.9.3'

gem 'will_paginate', '~>3.0.7'

gem 'resque', '~>1.25.2'

group :development do
  gem 'better_errors', '~>2.0.0'
  gem 'binding_of_caller', '~>0.7.2'
  gem 'spring', '~>1.1.3'

  # Lints
  gem 'rubocop', '~>0.26.1'
end

group :debugging, :development, :test do
  gem 'pry'
  gem 'byebug'
  gem 'pry-byebug'
  gem 'pry-nav'
  gem 'pry-stack_explorer'
end

group :test, :development do

  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner', github: 'bmabey/database_cleaner'

  # Modify time in tests
  gem 'timecop', '~>0.7.1'

  # Cucumber with JS
  gem 'poltergeist'

  # Save and open page cucumber
  gem 'launchy'

  gem 'shoulda-matchers'
end

group :production, :staging do
  gem 'rails_12factor', '~>0.0.2'
end
