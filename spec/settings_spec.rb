# frozen_string_literal: true

RSpec.describe(RackApi::Settings) do
  it "loads every application constant" do
    expect { RackApi.loader.eager_load }.not_to(raise_error)
  end

  it "allows HTTP boot without dashboard credentials when disabled" do
    settings = RackApi::Settings.new("RACK_ENV" => "production", "CLIENT_API_KEY" => "k" * 64)
    expect(settings.sidekiq_web_enabled?).to(be(false))
    expect { settings.validate_http! }.not_to(raise_error)
  end

  it "does not require HTTP credentials for a worker or console boot" do
    expect { RackApi::Settings.new("RACK_ENV" => "production") }.not_to(raise_error)
  end

  it "requires a strong API key for the HTTP application" do
    expect { settings_for("CLIENT_API_KEY" => "").validate_http! }.to(raise_error(ArgumentError, /CLIENT_API_KEY/))
  end

  it "requires a shared session secret when the dashboard is enabled" do
    expect do
      settings_for("SIDEKIQ_WEB_ENABLED" => "true", "SIDEKIQ_WEB_SESSION_SECRET" => "short").validate_http!
    end.to(raise_error(ArgumentError, /SIDEKIQ_WEB_SESSION_SECRET/))
  end

  it "rejects development dashboard passwords in production" do
    expect do
      settings_for("RACK_ENV" => "production", "SIDEKIQ_WEB_ENABLED" => "true", "SIDEKIQ_WEB_PASSWORD" => "dev").validate_http!
    end.to(raise_error(ArgumentError, /SIDEKIQ_WEB_PASSWORD/))
  end

  it "rejects invalid numeric and boolean configuration" do
    { "PORT" => "3000oops", "REDIS_DB" => "-1", "MAX_THREADS" => "0", "SIDEKIQ_WEB_ENABLED" => "yes" }.each do |name, value|
      expect { settings_for(name => value) }.to(raise_error(ArgumentError, /#{name}/))
    end
  end

  it "rejects inconsistent thread limits" do
    expect { settings_for("MIN_THREADS" => "6", "MAX_THREADS" => "5") }.to(raise_error(ArgumentError, /MIN_THREADS/))
  end

  it "separates HTTP and job concurrency" do
    settings = settings_for("MAX_THREADS" => "8", "SIDEKIQ_CONCURRENCY" => "3")
    expect(settings.max_threads).to(eq(8))
    expect(settings.sidekiq_concurrency).to(eq(3))
  end

  it "rejects wildcard CORS in production" do
    expect { settings_for("RACK_ENV" => "production", "CORS_ORIGINS" => "*") }.to(raise_error(ArgumentError, /CORS_ORIGINS/))
  end

  it "validates Redis URLs without revealing credentials" do
    expect { settings_for("REDIS_URL" => "http://user:secret@redis") }.to(raise_error(ArgumentError, "REDIS_URL must be a valid redis:// or rediss:// URL"))
  end
end
