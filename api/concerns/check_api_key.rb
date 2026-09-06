# frozen_string_literal: true

module CheckApiKey
  extend ActiveSupport::Concern

  included do
    before_action :check_api_key!, except: :not_found
  end

  private

  def check_api_key!
    provided_key = request.headers["Api-Key"].to_s
    expected_key = request.get_header("rack_api.settings").api_key
    unless Rack::Utils.secure_compare(Digest::SHA256.hexdigest(provided_key), Digest::SHA256.hexdigest(expected_key))
      raise RackApi::Errors::RequestError.new("Invalid API key", status: 401, code: "API_KEY_ERROR")
    end
  end
end
