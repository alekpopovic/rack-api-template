# frozen_string_literal: true

require_relative "config/initializer"

router = ActionDispatch::Routing::RouteSet.new

router.draw do
  root to: "application#error_404"
  scope "v1" do
    post "sign_in", to: "sign_in#handler"
  end
  match "*unmatched", to: "application#error_404", via: :all
end

app = Rack::Builder.new do
  use(Rack::Cors) do
    allow do
      origins("*")
      resource(
        "*",
        credentials: true,
        headers: :any,
        methods: %(get post put patch delete options head),
      )
    end
  end
  use(Rackup::Handler::Puma.run(router, Port: Application.config.port))
end

run app
