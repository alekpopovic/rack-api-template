# frozen_string_literal: true

module SignInHandler
  include AbstractController::Rendering
  include SignInValidator

  def handle(**args)
    validate(**args)
    render(json: {
      email: args[:email],
      password: args[:password],
    })
  end
end
