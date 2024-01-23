# frozen_string_literal: true

class ApplicationController < ActionController::API
  # include CheckAppApiKey
  include HandleHttpErrors
  include UnderscoreParams

  def error_404
    raise not_found_error("Action #{params[:unmatched]} not found")
  end
end
