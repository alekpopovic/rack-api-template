# frozen_string_literal: true

module RackApi
  class Settings
    attr_reader :environment, :app_name, :log_level, :port, :min_threads,
      :max_threads, :web_concurrency, :sidekiq_concurrency, :sidekiq_timeout,
      :redis_options, :max_request_bytes, :cors_origins

    def initialize(env)
      @env = env.to_h.freeze
      @environment = @env.fetch("RACK_ENV", "development")
      unless %w[development test production].include?(@environment)
        raise ArgumentError, "RACK_ENV must be development, test, or production"
      end
      @app_name = @env.fetch("APP_NAME", "rack-api")
      @log_level = @env.fetch("LOG_LEVEL", "INFO").upcase
      unless %w[DEBUG INFO WARN ERROR FATAL].include?(@log_level)
        raise ArgumentError, "LOG_LEVEL must be DEBUG, INFO, WARN, ERROR, or FATAL"
      end
      @port = integer("PORT", 3000, 1..65_535)
      @min_threads = integer("MIN_THREADS", 5)
      @max_threads = integer("MAX_THREADS", 5)
      raise ArgumentError, "MIN_THREADS must not exceed MAX_THREADS" if @min_threads > @max_threads

      @web_concurrency = integer("WEB_CONCURRENCY", 0, 0..128)
      @sidekiq_concurrency = integer("SIDEKIQ_CONCURRENCY", 5)
      @sidekiq_timeout = integer("SIDEKIQ_TIMEOUT", 25)
      @max_request_bytes = integer("MAX_REQUEST_BYTES", 1_048_576, 1..100_000_000)
      @sidekiq_web_enabled = boolean("SIDEKIQ_WEB_ENABLED", @environment == "development")
      @example_jobs_enabled = boolean("ENABLE_EXAMPLE_JOBS", @environment == "development")
      @cors_origins = @env.fetch("CORS_ORIGINS", "").split(",").map(&:strip).reject(&:empty?).freeze
      if production? && @cors_origins.include?("*")
        raise ArgumentError, "CORS_ORIGINS must list explicit origins in production"
      end

      redis_url = @env.fetch("REDIS_URL", "redis://127.0.0.1:6379")
      begin
        url = URI.parse(redis_url)
        raise URI::InvalidURIError unless %w[redis rediss].include?(url.scheme) && url.host
      rescue URI::InvalidURIError
        raise ArgumentError, "REDIS_URL must be a valid redis:// or rediss:// URL", cause: nil
      end
      @redis_options = { url: redis_url, db: integer("REDIS_DB", 1, 0..15), network_timeout: 2, pool_timeout: 2 }.freeze
    end

    def production?
      environment == "production"
    end

    def sidekiq_web_enabled?
      @sidekiq_web_enabled
    end

    def example_jobs_enabled?
      @example_jobs_enabled
    end

    def api_key
      required("CLIENT_API_KEY", minimum: 32)
    end

    def sidekiq_web_username
      required("SIDEKIQ_WEB_USERNAME")
    end

    def sidekiq_web_password
      required("SIDEKIQ_WEB_PASSWORD", minimum: production? ? 16 : 1)
    end

    def sidekiq_web_session_secret
      required("SIDEKIQ_WEB_SESSION_SECRET", minimum: 64)
    end

    def validate_http!
      api_key
      if sidekiq_web_enabled?
        sidekiq_web_username
        sidekiq_web_password
        sidekiq_web_session_secret
      end
      self
    end

    private

    def required(name, minimum: 1)
      value = @env[name]
      unless value && value.strip.length >= minimum
        raise ArgumentError, "#{name} must contain at least #{minimum} characters"
      end
      value
    end

    def integer(name, default, range = 1..1024)
      value = Integer(@env.fetch(name, default).to_s, 10)
      raise ArgumentError unless range.cover?(value)

      value
    rescue ArgumentError, TypeError
      raise ArgumentError, "#{name} must be an integer in #{range}"
    end

    def boolean(name, default)
      value = @env.fetch(name, default.to_s)
      raise ArgumentError, "#{name} must be true or false" unless %w[true false].include?(value)

      value == "true"
    end
  end
end
