# frozen_string_literal: true

module CheckAppApiKey
  extend ActiveSupport::Concern

  included do
    before_action :check_api_key!
  end

  private

  def check_api_key!
    if request.headers["Api-Key"].blank?
      render(
        json: {
          errors: [
            {
              code: Helpers::HttpStatusCustomCode::API_KEY_ERROR,
              message: "You need to setup Api-Key header to authorize this request.",
            },
          ],
        },
        status: :unauthorized,
      )
    elsif Base64.decode64(request.headers["Api-Key"]) != ENV["CLIENT_API_KEY"]
      render(
        json: {
          errors: [
            {
              code: Helpers::HttpStatusCustomCode::API_KEY_ERROR,
              message: "Wrong Api-Key.",
            },
          ],
        },
        status: :unauthorized,
      )
    end
  end
end
