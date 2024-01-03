# frozen_string_literal: true

module Helpers
  module Notification
    codes = {
      error_validation: "ERROR_VALIDATION",
      error_not_found: "ERROR_NOT_FOUND",
      error_bad_request: "ERROR_BAD_REQUEST",
      error_api_key: "ERROR_API_KEY",
    }

    codes.each { |k, v| const_set(k.upcase, v) }
  end
end
