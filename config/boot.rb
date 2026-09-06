# frozen_string_literal: true

ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)
require "bundler/setup"

ENV["RACK_ENV"] ||= "development"
if ENV["RACK_ENV"] == "development"
  require "dotenv"
  Dotenv.load(File.expand_path("../.env", __dir__))
end

require "rack"
require "action_controller"
require "action_dispatch"
require "dry-validation"
require "zeitwerk"
require "sidekiq"
require "json"
require "logger"
require "time"
require "securerandom"
require "digest"
require "uri"

module RackApi
  ROOT = File.expand_path("..", __dir__)

  class << self
    attr_reader :settings, :logger, :loader
  end

  @loader = Zeitwerk::Loader.new
  %w[lib api/controllers api/concerns contracts services jobs].each do |directory|
    @loader.push_dir(File.join(ROOT, directory))
  end
  @loader.setup

  @settings = Settings.new(ENV)
  @logger = Logging.build(@settings)
  ActionController::Base.logger = @logger
  ActionController::API.logger = @logger
  # RequestContext emits one correlated event with the final HTTP status.
  ActionController::LogSubscriber.detach_from(:action_controller)

  Sidekiq.configure_client do |config|
    config.redis = @settings.redis_options
    config.logger = @logger
  end

  @loader.eager_load if @settings.production?
end
