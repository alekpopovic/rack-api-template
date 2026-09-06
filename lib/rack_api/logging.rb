# frozen_string_literal: true

module RackApi
  module Logging
    class << self
      def build(settings, output: $stdout)
        Logger.new(output, level: settings.log_level).tap do |logger|
          logger.formatter = lambda do |severity, time, _program, message|
            fields = message.is_a?(Hash) ? message : { message: message.to_s }
            job_context = Sidekiq::Context.current.slice(:jid, :class, :elapsed)
            JSON.generate(fields.merge(job_context).merge(timestamp: time.utc.iso8601(3), level: severity, app: settings.app_name)) + "\n"
          end
        end
      end
    end
  end
end
