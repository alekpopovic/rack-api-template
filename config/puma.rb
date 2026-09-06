# frozen_string_literal: true

require_relative "boot"

settings = RackApi.settings
threads settings.min_threads, settings.max_threads
workers settings.web_concurrency
port settings.port
environment settings.environment
rackup File.join(RackApi::ROOT, "config.ru")
worker_timeout 3600 if settings.environment == "development"
pidfile ENV["PIDFILE"] if ENV["PIDFILE"] && !ENV["PIDFILE"].empty?
preload_app!
