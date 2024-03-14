# frozen_string_literal: true

require "dotenv/load"
require "zeitwerk"
require "rack"
require "rack/cors"
require "rack/session"
require "rack/handler/puma"
require "action_controller"
require "action_dispatch"
require "dry-validation"

loader = Zeitwerk::Loader.new
loader.push_dir("config/initializers")
loader.push_dir("lib")
loader.push_dir("jobs")
loader.push_dir("validators")
loader.push_dir("handlers")
loader.push_dir("api/concerns")
loader.push_dir("api/controllers")
loader.setup
