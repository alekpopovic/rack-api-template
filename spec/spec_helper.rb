# frozen_string_literal: true

ENV["RACK_ENV"] = "test"
require_relative "../config/boot"
require "rack/test"
require "stringio"

module AppSpecHelpers
  def settings_for(overrides = {})
    RackApi::Settings.new({
      "RACK_ENV" => "test",
      "CLIENT_API_KEY" => "test-api-key-" * 4,
      "SIDEKIQ_WEB_ENABLED" => "false",
      "SIDEKIQ_WEB_USERNAME" => "dashboard-user",
      "SIDEKIQ_WEB_PASSWORD" => "dashboard-password",
      "SIDEKIQ_WEB_SESSION_SECRET" => "test-session-secret-" * 8,
      "CORS_ORIGINS" => "https://client.example",
    }.merge(overrides))
  end
end

RSpec.shared_context("HTTP application") do
  include Rack::Test::Methods

  let(:settings) { settings_for }
  let(:log_output) { StringIO.new }
  let(:logger) { RackApi::Logging.build(settings, output: log_output) }
  let(:app) { RackApi::Application.build(settings: settings, logger: logger) }

  def authorize_api
    header "Api-Key", settings.api_key
  end

  def json_body
    JSON.parse(last_response.body)
  end
end

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!
  config.order = :random
  config.include(AppSpecHelpers)
  config.include_context("HTTP application", :http)
  config.expect_with(:rspec) { |expectations| expectations.syntax = :expect }
end
