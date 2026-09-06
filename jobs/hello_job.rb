# frozen_string_literal: true

class HelloJob
  include Sidekiq::Job

  sidekiq_options retry: 3

  def perform
    logger.info(event: "hello_job", message: "Hello world")
  end
end
