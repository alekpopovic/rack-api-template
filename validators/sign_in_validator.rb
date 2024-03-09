# frozen_string_literal: true

module SignInValidator
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
