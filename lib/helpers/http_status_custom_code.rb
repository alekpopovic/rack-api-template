# frozen_string_literal: true

module Helpers
  module HttpStatusCustomCode
    codes = {
      validation_error: "VALIDATION_ERROR",
      not_found_error: "NOT_FOUND_ERROR",
      bad_request_error: "BAD_REQUEST_ERROR",
      api_key_error: "API_KEY_ERROR",
    }

    codes.each { |k, v| const_set(k.upcase, v) }
  end
end
