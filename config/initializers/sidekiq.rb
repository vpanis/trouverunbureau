require 'sidekiq'

# Load the redis configuration
redis = AppConfiguration.for(:redis)
Sidekiq.configure_server do |config|
  config.redis = { host: redis.host, port: redis.port, password: redis.password }
end
