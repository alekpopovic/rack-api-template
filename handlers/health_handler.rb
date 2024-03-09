# frozen_string_literal: true

module HealthHandler
  include AbstractController::Rendering

  def handle
    render(json: {
      app: ENV["APP_NAME"],
      env: ENV["APP_ENV"],
    })
  end
end
