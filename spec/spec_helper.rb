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

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with(:rspec) do |c|
    c.syntax = :expect
  end
end
