require 'resque/server'

# Load the redis configuration from resque.yml
redis = AppConfiguration.for(:redis)
ENV['REDISTOGO_URL'] ||= "redis://#{ENV.fetch('REDIS_PORT_6379_TCP_ADDR', '127.0.0.1')}:6379"

uri = URI.parse(ENV['REDISTOGO_URL'])
Resque.redis = Redis.new(host: uri.host, port: uri.port, password: redis.password, thread_safe: true)

# Resque web auth
resque = AppConfiguration.for(:resque)
Resque::Server.use(Rack::Auth::Basic) do |user, password|
  password == resque.password && user == resque.user
end
