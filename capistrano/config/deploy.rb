# config valid only for current version of Capistrano
lock '3.4.0'

set :ssh_options, {forward_agent: true}

set :application, 'my_grocery_price_book_www'
set :repo_url, 'https://github.com/my-grocery-price-book/www.git'

set :rails_env, 'production'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/home/my_grocery_price_book_www'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :info

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push('config/database.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')
set :linked_dirs, fetch(:linked_dirs, []).push('log')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :rollbar_user, Proc.new { ENV['USER'] || ENV['USERNAME'] }

namespace :deploy do
  after :migrate, :db_seed do
    on roles(:db) do
      within release_path do
        execute :rake, 'db:seed'
      end
    end
  end
  after :finished, :newrelic_deploy do
    on roles(:db) do
      within release_path do
        execute :bundle, 'exec newrelic deployments', "--user=#{fetch :rollbar_user}", "--revision=#{fetch :current_revision}"
      end
    end
  end
  after :finished, :rollbar_deploy do
    on roles(:db) do
      within release_path do
        execute :rake, 'rollbar:deploy', "LOCAL_USER=#{fetch :rollbar_user}", "ROLLBAR_ENV=#{fetch :stage}", "REVISION=#{fetch :current_revision}"
      end
    end
  end
end
