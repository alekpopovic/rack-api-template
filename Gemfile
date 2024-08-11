# frozen_string_literal: true

source "https://rubygems.org"

ruby "3.3.4"

gem "zeitwerk"
gem "rake"
gem "rackup"
gem "rack-cors"
gem "actionpack"
gem "puma"
gem "dry-validation"
gem "configem"
gem "sidekiq"
gem "sidekiq-scheduler"

group :development do
  gem "foreman"
  gem "rb-fsevent"
  gem "rerun"
  gem "dotenv"
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

group :production do
  gem "concurrent-ruby"
end
