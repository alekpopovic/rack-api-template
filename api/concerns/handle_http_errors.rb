# frozen_string_literal: true

module HandleHttpErrors
  extend ActiveSupport::Concern

  included do
    rescue_from RackApi::Errors::ValidationError, with: :validation_error
  end

  private

  def validation_error(error)
    errors = error.errors.flat_map do |field, messages|
      messages.map { |message| { code: "VALIDATION_ERROR", field: field.to_s, message: message } }
    end
    render(json: { errors: errors, request_id: request.request_id }, status: :unprocessable_entity)
  end
end
