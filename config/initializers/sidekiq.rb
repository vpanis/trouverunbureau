require 'sidekiq'

# Load the redis configuration
redis = AppConfiguration.for(:redis)
redis_uri = ENV['REDISTOGO_URL'] || "redis://#{ENV.fetch('REDIS_PORT_6379_TCP_ADDR', redis.host)}:#{redis.port}"
Sidekiq.configure_server do |config|
  config.redis = { uri: URI.parse(redis_uri) }
end
