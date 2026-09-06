# frozen_string_literal: true

module RackApi
  module Dashboard
    class << self
      def build(settings)
        require "sidekiq/web"
        require "sidekiq-scheduler/web"
        require "rack/auth/basic"
        require "rack/session/cookie"

        username = Digest::SHA256.hexdigest(settings.sidekiq_web_username)
        password = Digest::SHA256.hexdigest(settings.sidekiq_web_password)
        Rack::Builder.new do
          use(Rack::Auth::Basic, "Sidekiq") do |provided_username, provided_password|
            Rack::Utils.secure_compare(Digest::SHA256.hexdigest(provided_username), username) &
              Rack::Utils.secure_compare(Digest::SHA256.hexdigest(provided_password), password)
          end
          use(Rack::Session::Cookie, key: "sidekiq.session", path: "/sidekiq",
            secret: settings.sidekiq_web_session_secret, same_site: :lax, httponly: true,
            secure: settings.production?, expire_after: 86_400)
          run(Sidekiq::Web)
        end.to_app
      end
    end
  end
end
