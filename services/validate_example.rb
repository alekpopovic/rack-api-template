# frozen_string_literal: true

class ValidateExample
  def initialize(contract: ExampleContract.new)
    @contract = contract
  end

  def call(input)
    result = @contract.call(input)
    raise RackApi::Errors::ValidationError, result.errors.to_h if result.failure?

    { email: result[:email], valid: true }
  end
end
