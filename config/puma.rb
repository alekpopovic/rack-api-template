# frozen_string_literal: true

require "concurrent-ruby"

require_relative "initializers/application"

threads Application.config.min_threads_count, Application.config.max_threads_count

worker_timeout 3600 if Application.config.environment == "development"

port Application.config.port

environment Application.config.environment

pidfile "tmp/pids/server.pid"

workers Concurrent.physical_processor_count

preload_app!
