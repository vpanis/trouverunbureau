
rake db:test:prepare && bundle exec rubocop app spec features -R && bundle exec rspec && bundle exec cucumber
