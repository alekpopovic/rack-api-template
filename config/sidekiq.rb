# frozen_string_literal: true

require_relative "boot"
require "sidekiq-scheduler"

Sidekiq.configure_server do |config|
  config.concurrency = RackApi.settings.sidekiq_concurrency
  config[:timeout] = RackApi.settings.sidekiq_timeout
  config.redis = RackApi.settings.redis_options
  config.logger = RackApi.logger
  unless RackApi.settings.example_jobs_enabled?
    config[:scheduler]&.fetch(:schedule, {})&.delete("hello_world")
  end
end
