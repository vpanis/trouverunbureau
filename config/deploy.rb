require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rvm'

task :deploy_prod => :environment do
  set :rails_env, 'production'
  set :restart_workers_cmd, "sudo restart_workers"
  set :branch, 'master'
  set :deploy_to, '/var/www/ds/prod'
  set :test_url, "http://prod.deskspotting.com"
  @command_valid = true
  invoke :deploy
end

task :deploy_beta => :environment do
  set :rails_env, 'staging'
  set :restart_workers_cmd, "sudo restart_workers_beta"
  set :branch, 'development'
  set :deploy_to, '/var/www/ds/beta'
  set :test_url, "http://beta.deskspotting.com"
  @command_valid = true
  invoke :deploy
end

set :domain, 'tinecon.com.br'
set :repository, 'git@github.com:liteboxmkt/deskspotting.git'
set :user, 'deskspotting'
set :port, '21890'

shared_dirs = [
  'tmp',
  'log',
  'public/uploads'
]

shared_files = []

set :shared_paths, (shared_dirs + shared_files)

set :forward_agent, true

task :environment do
  invoke :'rvm:use[ruby-2.1.5@default]'
end

task :log_prod do
  queue "tail -f /var/www/ds/prod#{deploy_to}/#{current_path}/log/production.log"
end

task :log_beta do
  queue "tail -f /var/www/ds/beta#{deploy_to}/#{current_path}/log/staging.log"
end

task :setup => :environment do
  shared_dirs.each do |shared_dir|
    queue! %[mkdir -p "#{deploy_to}/#{shared_path}/#{shared_dir}"]
    queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/#{shared_dir}"]
  end

  shared_files.each do |shared_file|
    queue! %[touch "#{deploy_to}/#{shared_path}/#{shared_file}"]
  end

  unless shared_files.empty?
    queue  %[echo "-----> Be sure to edit '#{shared_files.join(', ')}."]
  end

  queue %[
    repo_host=`echo #{repository} | sed -e 's/.*@//g' -e 's/:.*//g'` &&
    repo_port=`echo #{repository} | grep -o ':[0-9]*' | sed -e 's/://g'` &&
    if [ -z "${repo_port}" ]; then repo_port=22; fi &&
    ssh-keyscan -p $repo_port -H $repo_host >> ~/.ssh/known_hosts
  ]
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  to :before_hook do
    unless @command_valid
      puts "usage: mina [deploy_prod|deploy_beta] [-v]"
      exit 1
    end
  end
  to :after_hook do
    require 'rbconfig'
    is_win = RbConfig::CONFIG['host_os'] =~ /mswin|mingw/
    unless is_win
      queue %[echo "-----> Testing site"]
      queue %[
        red=`tput setaf 1`; green=`tput setaf 2`; reset=`tput sgr0`
        echo "${green}wget #{test_url}"
        output=`wget -O /dev/null #{test_url} 2>&1`
        if [ $? -ne 0 ]; then
          echo "${red}Error accessing site:\n$output"
          echo
          echo "!!! ATTENTION: RIGHT NOW #{test_url} RUNNING IN #{domain}:#{deploy_to}/#{current_path} IS DOWN !!!"
        else
          echo "${green}ok"
        fi
        echo ${reset}
      ]
    end
  end
  deploy do
    queue! %[echo "Using ruby version `ruby -v` in path `which ruby`."]
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    queue %[echo "-----> Bundle"]
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'
    invoke "rake[mangopay:deploy_hooks]"

    to :launch do
      queue %[
        p=#{deploy_to}/#{current_path}/tmp &&
        if [ ! -d $p ]; then mkdir -p $p; fi
      ]
      queue %[echo 'Restarting app...']
      queue! %[touch #{deploy_to}/#{current_path}/tmp/restart.txt]
      if restart_workers
        queue %[echo 'Restarting workers...']
        queue! %[restart_workers_cmd]
      end
    end
  end
end
