# frozen_string_literal: true

module HealthHandler
  include AbstractController::Rendering

  def handle
    render(json: {
      app: 'rack-api',
      env: ENV["RACK_ENV"],
    })
  end
end
