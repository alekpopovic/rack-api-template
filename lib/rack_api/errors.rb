# frozen_string_literal: true

module RackApi
  module Errors
    class RequestError < StandardError
      attr_reader :status, :code

      def initialize(message, status:, code:)
        @status = status
        @code = code
        super(message)
      end
    end

    class ValidationError < StandardError
      attr_reader :errors

      def initialize(errors)
        @errors = errors
        super("Request validation failed")
      end
    end
  end
end
