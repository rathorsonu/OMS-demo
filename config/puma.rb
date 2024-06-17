# config/puma.rb
environment ENV.fetch("RAILS_ENV") { "development" }

# Specifies the number of worker processes.
workers ENV.fetch("WEB_CONCURRENCY") { 2 }

# Specifies the minimum and maximum number of threads per worker.
threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
threads threads_count, threads_count

# Preload the application before workers are forked.
preload_app!

# Specifies the port to run on.
port ENV.fetch("PORT") { 3000 }

# Specifies the PID and state file locations.
pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

# Specifies the log files.
stdout_redirect 'log/puma.stdout.log', 'log/puma.stderr.log', true

# Daemonize the server (run in the background).
daemonize true if ENV.fetch("RAILS_ENV") == "production"

on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end
