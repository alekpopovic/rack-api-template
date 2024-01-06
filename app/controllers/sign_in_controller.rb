# frozen_string_literal: true

class SignInController < ApplicationController
  include SignInAction

  def handler
    handle(
      email:    params[:email],
      password: params[:password],
    )
  end
end
