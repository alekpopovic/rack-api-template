# frozen_string_literal: true

class ExamplesController < ApplicationController
  def show
    render(json: { message: "Hello" })
  end

  def validate
    render(json: ValidateExample.new.call(request.request_parameters))
  end
end
