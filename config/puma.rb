# Fetching the maximum and minimum threads count from environment variables
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

# Setting the port for Puma to listen on
port ENV.fetch("PORT") { 3000 }

# Setting the environment for Puma
environment ENV.fetch("RAILS_ENV") { "production" }

# Setting the pidfile for Puma
pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

# Setting the number of workers (commented out as it's optional)
# workers ENV.fetch("WEB_CONCURRENCY") { 2 }

# Preloading the app (commented out as it's optional)
# preload_app!

# Running Puma as a daemon
daemonize true

# Setting the directory and rackup file
directory '/home/deploy/oms_demo/current'
rackup "/home/deploy/oms_demo/current/config.ru"

# Setting the environment explicitly (even though it's already set above)
environment 'production'

# Setting the pidfile and state file locations
pidfile "/home/deploy/oms_demo/shared/tmp/pids/puma.pid"
state_path "/home/deploy/oms_demo/shared/tmp/pids/puma.state"

# Redirecting stdout and stderr logs
stdout_redirect "/home/deploy/oms_demo/shared/log/puma.stdout.log", "/home/deploy/oms_demo/shared/log/puma.stderr.log", true

# Allowing puma to be restarted by `rails restart` command
plugin :tmp_restart
