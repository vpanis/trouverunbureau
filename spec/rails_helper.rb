ENV['RAILS_ENV'] ||= 'test'
require 'support/spec_helper'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

require 'simplecov'
include ActionDispatch::TestProcess

# Runs migrations (needed from 4.1.x)
ActiveRecord::Migration.maintain_test_schema!

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.include ActionDispatch::TestProcess
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.infer_spec_type_from_file_location!
  config.include Devise::TestHelpers, type: :controller
  config.order = 'random'
end
