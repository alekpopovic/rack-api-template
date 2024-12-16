# frozen_string_literal: true

module ExampleHandler
  include AbstractController::Rendering

  def handle()
    render(json: {
      message: "Hello"
    })
  end
end