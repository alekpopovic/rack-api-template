# frozen_string_literal: true

require "sidekiq"
require "sidekiq-scheduler"
require_relative "initializers/application"

Sidekiq.configure_server do |config|
  config.concurrency = 5
  config.redis = {
    url: Application.config.redis_url,
    db: 1,
  }
  config.logger.formatter = Sidekiq::Logger::Formatters::JSON.new if Application.config.environment == "production"
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: Application.config.redis_url,
    db: 1,
  }
end
