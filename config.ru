# frozen_string_literal: true

require "dotenv/load" if ENV["RACK_ENV"] == "development"
require "zeitwerk"
require "rack"
require "rackup"
require "rack/cors"
require "rack/handler/puma"
require "action_controller"
require "action_dispatch"
require "dry-validation"
require "securerandom"
require "rack/session"
require 'sidekiq/web'
require 'sidekiq-scheduler/web'

loader = Zeitwerk::Loader.new
loader.push_dir("models")
loader.push_dir("lib")
loader.push_dir("jobs")
loader.push_dir("validators")
loader.push_dir("handlers")
loader.push_dir("api/concerns")
loader.push_dir("api/controllers")
loader.setup

router = ActionDispatch::Routing::RouteSet.new

router.draw do
  root to: "application#error_404"
  get "sidekiq", to: Sidekiq::Web
  get "health", to: "health#handler"
  post "sign_in", to: "sign_in#handler"
  match "*unmatched", to: "application#error_404", via: :all
end

use Rack::Session::Cookie, secret: SecureRandom.hex(32), same_site: true, max_age: 86400

map('/sidekiq') { run Sidekiq::Web }

use(Rackup::Handler::Puma.run(router, Port: ENV.fetch("PORT"), Verbose: true))

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

Sidekiq::Web.use Rack::Auth::Basic do |username, password|
  [username, password] == [ENV.fetch('SIDEKIQ_WEB_USERNAME'), ENV.fetch('SIDEKIQ_WEB_PASSWORD')]
end
