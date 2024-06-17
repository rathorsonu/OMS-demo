# config valid for current version and patch releases of Capistrano
require 'capistrano/puma'

lock "~> 3.18.1"

set :application, 'oms_demo'
set :repo_url, 'git@github.com:rathorsonu/OMS-demo.git' # Edit this to match your repository
set :branch, :main
set :deploy_to, '/home/deploy/oms_demo'
set :puma_conf, "/home/deploy/oms_demo/shared/config/puma.rb"
set :use_sudo, true
set :pty, true

set :branch, 'main'
set :linked_files, %w{config/master.key config/database.yml}
append :linked_files, 'config/master.key'
append :linked_files, 'config/database.yml'
set :rails_env, 'production'
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')
# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
set :keep_releases, 5
set :rvm_type, :user
set :rvm_ruby_version, 'ruby-3.1.0' # Edit this if you are using MRI Ruby

set :puma_rackup, -> { File.join(current_path, 'config.ru') }
set :puma_state, "#{shared_path}/tmp/pids/puma.state"
set :puma_pid, "#{shared_path}/tmp/pids/puma.pid"
set :puma_bind, "unix://#{shared_path}/tmp/sockets/puma.sock"    #accept array for multi-bind
set :puma_conf, "#{shared_path}/config/puma.rb"
set :puma_access_log, "#{shared_path}/log/puma_error.log"
set :puma_error_log, "#{shared_path}/log/puma_access.log"
set :puma_role, :app
set :puma_env, fetch(:rack_env, fetch(:rails_env, 'production'))
set :puma_threads, [0, 8]
set :puma_workers, 0
set :puma_worker_timeout, nil
set :puma_init_active_record, true
set :puma_preload_app, false

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", 'config/master.key'

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system", "vendor", "storage"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

# ps aux | grep puma    # Get puma pid
# kill -s SIGUSR2 pid   # Restart puma
# kill -s SIGTERM pid   # Stop puma
namespace :deploy do

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end


end

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end

  before :start, :make_dirs

  desc 'Start Puma'
  task :start do
    on roles(:app) do
      execute "sudo systemctl start puma"
    end
  end

  desc 'Stop Puma'
  task :stop do
    on roles(:app) do
      execute "sudo systemctl stop puma"
    end
  end

  desc 'Restart Puma'
  task :restart do
    on roles(:app) do
      execute "sudo systemctl restart puma"
    end
  end
end

after 'deploy:publishing', 'puma:restart'