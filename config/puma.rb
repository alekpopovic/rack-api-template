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

require_relative "initializers/application"

threads Application.config.min_threads_count, Application.config.max_threads_count
worker_timeout 3600 if Application.config.environment == "development"
port Application.config.port { 3000 }
environment Application.config.environment { "development" }
pidfile Application.config.pidfile { "tmp/pids/server.pid" }
workers Application.config.web_concurrency { 2 }
preload_app!
