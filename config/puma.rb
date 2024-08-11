# frozen_string_literal: true

max_threads_count = ENV.fetch("MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

if ENV["RACK_ENV"] == "production"
  require "concurrent-ruby"
  worker_count = Integer(ENV.fetch("WEB_CONCURRENCY") { Concurrent.physical_processor_count })
  workers worker_count if worker_count > 1
end

worker_timeout 3600 if ENV["RACK_ENV"] == "development"

port ENV.fetch("PORT") { 3000 }

environment ENV.fetch("RACK_ENV") { "development" }

pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

preload_app!
