# frozen_string_literal: true

class HealthController < ApplicationController
  include HealthHandler

  def handler
    handle
  end
end
