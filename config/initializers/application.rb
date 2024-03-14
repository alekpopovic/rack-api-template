# frozen_string_literal: true

require "dotenv/load"
require "configem"

Application = Class.new do
  include Configem
end

Application.configure do |config|
  config.environment = ENV.fetch("RACK_ENV")
  config.port = ENV.fetch("PORT")
  config.max_threads_count = ENV.fetch("MAX_THREADS")
  config.min_threads_count = ENV.fetch("MIN_THREADS")
  config.pidfile = ENV.fetch("PIDFILE")
  config.web_concurrency = ENV.fetch("WEB_CONCURRENCY")
  config.redis_url = ENV.fetch("REDIS_URL")
end
