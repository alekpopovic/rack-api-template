# frozen_string_literal: true

require_relative "config/boot"

run RackApi::Application.build
