# frozen_string_literal: true

require "dotenv/load"
require "zeitwerk"
require "rack"
require "rack/cors"
require "rack/handler/puma"
require "action_controller"
require "action_dispatch"
require "dry-validation"

loader = Zeitwerk::Loader.new
loader.push_dir("config/initializers")
loader.push_dir("lib")
loader.push_dir("app/actions")
loader.push_dir("app/concerns")
loader.push_dir("app/controllers")
loader.setup
