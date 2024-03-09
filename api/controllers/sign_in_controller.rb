# frozen_string_literal: true

class SignInController < ApplicationController
  include SignInHandler

  def handler
    handle(
      email:    params[:email],
      password: params[:password],
    )
  end
end
