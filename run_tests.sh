RAILS_ENV=test bundle exec rake db:drop; RAILS_ENV=test bundle exec rake db:create; RAILS_ENV=test bundle exec rake db:migrate
bundle exec rubocop app spec features -R && bundle exec rspec && bundle exec cucumber
