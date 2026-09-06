# frozen_string_literal: true

RSpec.describe("Sidekiq dashboard", :http) do
  let(:settings) { settings_for("SIDEKIQ_WEB_ENABLED" => "true") }

  it "requires authentication" do
    get "/sidekiq/"
    expect(last_response.status).to(eq(401))
    expect(last_response.headers["www-authenticate"]).to(eq('Basic realm="Sidekiq"'))
  end

  it "rejects an incorrect username or password" do
    [["wrong-user", "dashboard-password"], ["dashboard-user", "wrong-password"]].each do |credentials|
      basic_authorize(*credentials)
      get "/sidekiq/"
      expect(last_response.status).to(eq(401))
    end
  end

  it "rejects malformed Basic authentication" do
    header "Authorization", "Basic #{["no-colon"].pack("m0")}"
    get "/sidekiq/"
    expect(last_response.status).to(eq(400))
  end

  it "protects dashboard assets" do
    get "/sidekiq/stylesheets/style.css"
    expect(last_response.status).to(eq(401))
  end

  it "serves assets after authentication" do
    basic_authorize "dashboard-user", "dashboard-password"
    get "/sidekiq/stylesheets/style.css"
    expect(last_response.status).to(eq(200))
    expect(last_response.content_type).to(include("text/css"))
  end

  it "provides a session for authenticated requests" do
    redis = double("Redis")
    allow(Sidekiq).to(receive(:redis).and_yield(redis))
    expect(redis).to(receive(:llen).with("queue:default").and_return(0))
    basic_authorize "dashboard-user", "dashboard-password"
    head "/sidekiq/"
    expect(last_response.status).to(eq(200))
    expect(last_response.headers["set-cookie"]).to(include("sidekiq.session=", "path=/sidekiq", "httponly", "samesite=lax"))
  end

  it "rejects actions without a CSRF token" do
    basic_authorize "dashboard-user", "dashboard-password"
    post "/sidekiq/change_locale", locale: "en"
    expect(last_response.status).to(eq(403))
  end

  it "can be disabled independently of the API" do
    disabled_app = RackApi::Application.build(settings: settings_for, logger: logger)
    response = Rack::MockRequest.new(disabled_app).get("/sidekiq/")
    expect(response.status).to(eq(404))
    expect(Rack::MockRequest.new(disabled_app).get("/health").status).to(eq(200))
  end

  it "uses secure cookies in production" do
    production_app = RackApi::Application.build(settings: settings_for("RACK_ENV" => "production", "SIDEKIQ_WEB_ENABLED" => "true"), logger: logger)
    redis = double("Redis", llen: 0)
    allow(Sidekiq).to(receive(:redis).and_yield(redis))
    response = Rack::MockRequest.new(production_app).head("https://example.com/sidekiq/",
      "HTTP_AUTHORIZATION" => "Basic #{["dashboard-user:dashboard-password"].pack("m0")}")
    expect(response.status).to(eq(200))
    expect(response.headers["set-cookie"]).to(include("secure", "httponly"))
  end
end
