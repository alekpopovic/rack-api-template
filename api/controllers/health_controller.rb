# frozen_string_literal: true

class HealthController < ApplicationController
  skip_before_action :check_api_key!

  def live
    render(json: { status: "ok", app: request.get_header("rack_api.settings").app_name })
  end

  def ready
    Sidekiq.redis { |redis| redis.call("PING") }
    render(json: { status: "ok", checks: { redis: "ok" } })
  rescue RedisClient::Error, ConnectionPool::TimeoutError
    render(json: { status: "unavailable", checks: { redis: "unavailable" } }, status: :service_unavailable)
  end
end
