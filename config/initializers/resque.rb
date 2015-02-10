require 'resque/server'

# Load the redis configuration from resque.yml
redis = AppConfiguration.for(:redis)
Resque.redis = Redis.new(host: redis.host, port: redis.port, password: redis.password, thread_safe: true)

# Resque web auth
resque = AppConfiguration.for(:resque)
Resque::Server.use(Rack::Auth::Basic) do |user, password|
  password == resque.password && user == resque.user
end