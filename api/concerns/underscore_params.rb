# frozen_string_literal: true

module UnderscoreParams
  extend ActiveSupport::Concern

  included do
    before_action :underscore_all_params!
  end

  private

  def underscore_all_params!
    params.deep_transform_keys!(&:underscore)
  end
end
