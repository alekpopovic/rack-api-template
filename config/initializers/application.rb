# frozen_string_literal: true

# @license
#
# © CODEPOP 2015. All rights reserved.
#
# This copyright notice and any related information provided is “copyright
# management information” under the Digital Millennium Copyright Act.
# Such notices and language are used to deter, detect, and police copyright
# infringement, and their maintenance on copies of the source code is one
# of the conditions for lawful use of the source code. As such, any removal
# or alteration of such copyright management information without the express
# written permission CODEPOP will result in copyright
# infringement, and is prohibited.
#
# Confidential

require "configem"

Application = Class.new do
  include Configem
end

Application.configure do |config|
  config.environment = ENV.fetch("RACK_ENV")
  config.port = ENV.fetch("PORT")
  config.max_threads_count = ENV.fetch("MAX_THREADS")
  config.min_threads_count = ENV.fetch("MIN_THREADS")
  config.pidfile = ENV.fetch("PIDFILE")
  config.web_concurrency = ENV.fetch("WEB_CONCURRENCY")
end
