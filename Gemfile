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

source "https://rubygems.org"

gem "zeitwerk"
gem "rake"
gem "rackup"
gem "rack-cors"
gem "actionpack"
gem "puma"
gem "dry-validation"
gem "dotenv"
gem "configem"

group :development do
  gem "foreman"
  gem "rb-fsevent"
  gem "rerun"
end

group :development, :test do
  gem "debug", platforms: [:mri, :mingw, :x64_mingw]
  gem "faker"
  gem "rubocop-shopify", require: false
end

group :test do
  gem "factory_bot"
  gem "rspec"
  gem "rack-test"
end
