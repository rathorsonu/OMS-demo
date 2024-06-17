
# config valid for current version and patch releases of Capistrano
require 'capistrano/puma'

lock "~> 3.18.1"

set :application, 'oms_demo'
set :repo_url, 'git@github.com:rathorsonu/OMS-demo.git' # Edit this to match your repository
set :branch, 'main'
set :deploy_to, '/home/deploy/oms_demo'
set :rvm_type, :user
set :rvm_ruby_version, 'ruby-3.1.0'

set :linked_files, %w{config/master.key config/database.yml}
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

set :puma_conf, "#{shared_path}/config/puma.rb"
set :puma_access_log, "#{shared_path}/log/puma_access.log"
set :puma_error_log, "#{shared_path}/log/puma_error.log"

# Puma settings
set :puma_role, :app
set :puma_env, fetch(:rack_env, fetch(:rails_env, 'production'))
set :puma_threads, [0, 8]
set :puma_workers, 0
set :puma_worker_timeout, nil
set :puma_init_active_record, true
set :puma_preload_app, false

# Puma systemd commands (adjust as needed)
namespace :puma do
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

# Hooks
after 'deploy:publishing', 'puma:restart'
