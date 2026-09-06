# frozen_string_literal: true

source "https://rubygems.org"

ruby file: ".ruby-version"

gem "zeitwerk"
gem "rake"
gem "rackup"
gem "rack-cors"
gem "rack-session"
gem "cgi"
gem "actionpack"
gem "puma", "~> 7.2", ">= 7.2.1"
gem "dry-validation"
gem "sidekiq"
# Sidekiq 8.0.3 uses the positional timeout API removed in connection_pool 3.
gem "connection_pool", "~> 2.5"
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
  gem "bundler-audit", require: false
end

group :test do
  gem "factory_bot"
  gem "rspec"
  gem "rack-test"
end
