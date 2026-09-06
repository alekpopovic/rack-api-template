# frozen_string_literal: true

class ApplicationController < ActionController::API
  include CheckApiKey
  include HandleHttpErrors

  def not_found
    render(json: { errors: [{ code: "NOT_FOUND_ERROR", message: "Route not found" }], request_id: request.request_id }, status: :not_found)
  end
end
