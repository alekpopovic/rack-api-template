# frozen_string_literal: true

require_relative "initializers/application"

threads Application.config.min_threads_count, Application.config.max_threads_count
worker_timeout 3600 if Application.config.environment == "development"
port Application.config.port { 3000 }
environment Application.config.environment { "development" }
pidfile Application.config.pidfile { "tmp/pids/server.pid" }
workers Application.config.web_concurrency { 2 }
preload_app!
