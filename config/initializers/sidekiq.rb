# Sidekiq configuration file

require 'sidekiq'
require 'sidekiq/web'

url = ''
if ENV['REDISCLOUD_URL']
  url = ENV['REDISCLOUD_URL']
elsif ENV['REDISTOGO_URL']
  url = ENV['REDISTOGO_URL']
else
  url = "redis://#{ENV.fetch('REDIS_1_PORT_6379_TCP_ADDR', '127.0.0.1')}:6379"
end

Sidekiq.configure_server do |config|
  config.redis = { size: 30, url: url }
  config.error_handlers << proc { |exception, context| Airbrake.notify_or_ignore(exception, parameters: context) }
end

Sidekiq.configure_client do |config|
  config.redis = { url: url }
  config.error_handlers << proc { |exception, context| Airbrake.notify_or_ignore(exception, parameters: context) }
end

sidekiq = AppConfiguration.for(:sidekiq)

# Sidekiq::Web.use Rack::Auth::Basic do |username, password|
#   username == ENV[""] && password == sidekiq.password
# end
