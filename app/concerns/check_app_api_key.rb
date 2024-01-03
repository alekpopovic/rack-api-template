# frozen_string_literal: true

# @license
#
# © CODEPOP 2015. All rights reserved.
#
# This copyright notice and any related information provided is “copyright
# management information” under the Digital Millennium Copyright Act.
# Such notices and language are used to deter, detect, and police copyright
# infringement, and their maintenance on copies of the source code is one
# of the conditions for lawful use of the source code. As such, any removal
# or alteration of such copyright management information without the express
# written permission CODEPOP will result in copyright
# infringement, and is prohibited.
#
# Confidential

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
