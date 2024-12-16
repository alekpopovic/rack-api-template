# frozen_string_literal: true

class ExampleController < ApplicationController
  include ExampleHandler

  def handler
    handle
  end
end
