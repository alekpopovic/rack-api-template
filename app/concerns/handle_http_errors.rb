# frozen_string_literal: true

module HandleHttpErrors
  extend ActiveSupport::Concern

  included do
    rescue_from RuntimeError,                                 with: -> { nil }
    rescue_from ArgumentError,                                with: ->(e) { validation_error(e) }
    rescue_from ActionDispatch::Http::Parameters::ParseError, with: ->(e) { bad_request_error(e) }
  end

  private

  def validation_error(errors)
    obj = []
    if errors.is_a?(Hash)
      errors.each do |key, value|
        obj << {
          code: Helpers::HttpStatusCustomCode::VALIDATION_ERROR,
          message: "#{key.capitalize} #{value[0].humanize.downcase}",
        }
      end
    else
      obj << {
        code: Helpers::HttpStatusCustomCode::VALIDATION_ERROR,
        message: errors,
      }
    end
    render(json: { errors: obj }, status: :unprocessable_entity)
  end

  def not_found_error(error)
    render(
      json: {
        errors: [{
          code: Helpers::HttpStatusCustomCode::NOT_FOUND_ERROR,
          message: error,
        }],
      },
      status: :not_found,
    )
  end

  def bad_request_error(error)
    render(
      json: {
        errors: [{
          code: Helpers::HttpStatusCustomCode::BAD_REQUEST_ERROR,
          message: error,
        }],
      },
      status: :bad_request,
    )
  end
end
