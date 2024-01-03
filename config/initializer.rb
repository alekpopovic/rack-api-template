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
