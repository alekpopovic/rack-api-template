# frozen_string_literal: true

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
gem "sidekiq"
gem "sidekiq-scheduler"
gem "railties"

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
