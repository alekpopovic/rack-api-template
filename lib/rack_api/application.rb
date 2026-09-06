# frozen_string_literal: true

require "rack/cors"

module RackApi
  module Application
    class << self
      def build(settings: RackApi.settings, logger: RackApi.logger)
        settings.validate_http!
        router = ActionDispatch::Routing::RouteSet.new
        router.draw do
          get "health", to: "health#live"
          get "health/live", to: "health#live"
          get "health/ready", to: "health#ready"
          get "examples", to: "examples#show"
          post "examples/validate", to: "examples#validate"
          root to: "application#not_found"
          match "*unmatched", to: "application#not_found", via: :all
        end

        dashboard = Dashboard.build(settings) if settings.sidekiq_web_enabled?
        Rack::Builder.new do
          use(Rack::Head)
          use(Middleware::RequestContext, settings: settings, logger: logger)
          map("/sidekiq") { run(dashboard) } if dashboard
          map("/") do
            use(Rack::Cors) do
              allow do
                origins(*settings.cors_origins)
                resource("*", headers: ["Content-Type", "Api-Key", "X-Request-ID"],
                  expose: ["X-Request-ID"], methods: [:get, :post, :options, :head])
              end
            end
            use(Middleware::JsonBody, max_bytes: settings.max_request_bytes)
            run(router)
          end
        end.to_app
      end
    end
  end
end
