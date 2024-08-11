# frozen_string_literal: true

require "sidekiq-scheduler"

class HelloJob
  include Sidekiq::Job

  def perform
    puts "Hello world"
  end
end
