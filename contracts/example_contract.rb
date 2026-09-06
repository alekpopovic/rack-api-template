# frozen_string_literal: true

class ExampleContract < Dry::Validation::Contract
  json do
    config.validate_keys = true
    required(:email).filled(:string, max_size?: 254)
    required(:password).filled(:string, max_size?: 1024)
  end

  rule(:email) do
    key.failure("must be a valid email address") unless value.match?(URI::MailTo::EMAIL_REGEXP)
  end
end
