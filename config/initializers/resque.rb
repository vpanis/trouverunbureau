require 'resque/server'

# Load the redis configuration from resque.yml
resque = AppConfiguration.for('/config/resque')[Rails.env.to_s]
Resque.redis = Redis.new(host: resque["host"], port: resque["port"], password: resque["password"], thread_safe: true)

# Resque web auth
resque_auth = AppConfiguration.for("resque-web")
Resque::Server.use(Rack::Auth::Basic) do |user, password|
  password == resque_auth.password && user == resque_auth.user
end