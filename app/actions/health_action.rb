# frozen_string_literal: true

module HealthAction
  include AbstractController::Rendering

  def handle
    render(json: {
      app: ENV["APP_NAME"],
      env: ENV["APP_ENV"],
    })
  end

  private

  def validate(**args)
    args.assert_valid_keys(
      :email,
      :password,
    )

    validator = Validator.new.call(
      email:    args[:email],
      password: args[:password],
    )

    raise validation_error(
      validator.errors.to_h,
    ) if validator.errors.any?
  end

  class Validator < Dry::Validation::Contract
    params do
      required(:email).filled(:string)
      required(:password).filled(:string)
    end
  end
end
