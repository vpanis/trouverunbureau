require 'resque/server'

# Load the redis configuration from resque.yml
Resque.redis = YAML.load_file(File.join(Rails.root, "config", "resque.yml"))[Rails.env.to_s]

resque_auth = AppConfiguration.for(:resque)
# Resque web auth
Resque::Server.use(Rack::Auth::Basic) do |user, password|
  password == resque_auth.password && user == resque_auth.user
end