# frozen_string_literal: true

require_relative "initializers/application"

threads Application.config.min_threads_count, Application.config.max_threads_count

worker_timeout 3600 if Application.config.environment == "development"

port Application.config.port { 3000 }

environment Application.config.environment { "development" }

pidfile Application.config.pidfile { "tmp/pids/server.pid" }

if Application.config.environment == "production"
  require "concurrent-ruby"
  worker_count = Integer(Application.config.web_concurrency { Concurrent.physical_processor_count })
  workers worker_count if worker_count > 1
end

preload_app!
