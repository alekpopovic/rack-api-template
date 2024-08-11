# frozen_string_literal: true

require "dotenv/load" if ENV["RACK_ENV"] == "development"
require "sidekiq"
require "sidekiq-scheduler"
require "zeitwerk"

loader = Zeitwerk::Loader.new
loader.push_dir("jobs")
loader.setup

Sidekiq.configure_server do |config|
  config.concurrency = 5
  config.redis = {
    url: ENV["REDIS_URL"],
    db: 1,
  }
  config.logger.formatter = Sidekiq::Logger::Formatters::JSON.new if ENV["RACK_ENV"] == "production"
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: ENV["REDIS_URL"],
    db: 1,
  }
end
