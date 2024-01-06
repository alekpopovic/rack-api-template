# frozen_string_literal: true

class HealthController < ApplicationController
  include HealthAction

  def handler
    handle
  end
end
