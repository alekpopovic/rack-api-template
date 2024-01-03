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

module SignInAction
  include AbstractController::Rendering

  def handle(**args)
    validate(**args)
    render(json: {
      email: args[:email],
      password: args[:password],
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
