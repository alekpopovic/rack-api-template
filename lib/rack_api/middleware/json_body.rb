# frozen_string_literal: true

module RackApi
  module Middleware
    class JsonBody
      def initialize(app, max_bytes:)
        @app = app
        @max_bytes = max_bytes
      end

      def call(env)
        input = env["rack.input"]
        if input
          body = input.read(@max_bytes + 1).to_s
          if body.bytesize > @max_bytes
            raise Errors::RequestError.new("Request body is too large", status: 413, code: "PAYLOAD_TOO_LARGE")
          end
          unless body.empty?
            unless env["CONTENT_TYPE"].to_s.split(";", 2).first == "application/json"
              raise Errors::RequestError.new("Use application/json", status: 415, code: "UNSUPPORTED_MEDIA_TYPE")
            end
            parameters = JSON.parse(body)
            unless parameters.is_a?(Hash)
              raise Errors::RequestError.new("JSON body must be an object", status: 400, code: "BAD_REQUEST_ERROR")
            end
            # Parse before Action Dispatch so its parse-error logger can never
            # write the raw request body, including credentials, to the log.
            env["action_dispatch.request.request_parameters"] = parameters
          end
          input.rewind
        end
        @app.call(env)
      rescue JSON::ParserError
        raise Errors::RequestError.new("Invalid JSON body", status: 400, code: "BAD_REQUEST_ERROR")
      end
    end
  end
end
