# frozen_string_literal: true

module RackApi
  module Middleware
    class RequestContext
      FILTERED_PARAMETERS = [:password, :password_confirmation, :token, :secret, :api_key, :authorization].freeze

      def initialize(app, settings:, logger:)
        @app = app
        @settings = settings
        @logger = logger
      end

      def call(env)
        started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        supplied_id = env["HTTP_X_REQUEST_ID"].to_s
        request_id = supplied_id.ascii_only? && supplied_id.match?(/\A[a-zA-Z0-9_-]{1,64}\z/) ? supplied_id : SecureRandom.uuid
        env["action_dispatch.request_id"] = request_id
        env["action_dispatch.parameter_filter"] = FILTERED_PARAMETERS
        env["action_dispatch.logger"] = @logger
        env["rack.logger"] = @logger
        env["rack_api.settings"] = @settings

        status, headers, body = dispatch(env, request_id)
        headers = headers.merge("x-request-id" => request_id, "x-content-type-options" => "nosniff")
        headers["cache-control"] = "no-store" if headers["content-type"].to_s.start_with?("application/json")
        @logger.info(event: "http_request", request_id: request_id, method: env["REQUEST_METHOD"],
          path: env["PATH_INFO"].to_s.encode("UTF-8", invalid: :replace, undef: :replace)[0, 512],
          status: status, duration_ms: ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - started) * 1000).round(2))
        [status, headers, body]
      end

      private

      def dispatch(env, request_id)
        @app.call(env)
      rescue Errors::RequestError => error
        error_response(error.status, error.code, error.message, request_id)
      rescue ActionController::BadRequest, ActionDispatch::Http::Parameters::ParseError,
        Rack::QueryParser::ParameterTypeError, Rack::QueryParser::InvalidParameterError
        error_response(400, "BAD_REQUEST_ERROR", "Invalid request", request_id)
      rescue StandardError => error
        # Exception messages may contain passwords or request bodies. Record the
        # class and source locations, and correlate using the request ID instead.
        @logger.error(event: "http_error", request_id: request_id, error_class: error.class.name,
          backtrace: error.backtrace&.first(10))
        error_response(500, "INTERNAL_SERVER_ERROR", "Internal server error", request_id)
      end

      def error_response(status, code, message, request_id)
        [status, { "content-type" => "application/json", "cache-control" => "no-store" },
          [JSON.generate(errors: [{ code: code, message: message }], request_id: request_id)]]
      end
    end
  end
end
