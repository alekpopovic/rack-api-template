# frozen_string_literal: true

RSpec.describe("API", :http) do
  it "keeps liveness independent of Redis and authentication" do
    expect(Sidekiq).not_to(receive(:redis))
    get "/health/live"
    expect(last_response.status).to(eq(200))
    expect(json_body).to(eq("status" => "ok", "app" => "rack-api"))
    expect(last_response.headers).not_to(have_key("set-cookie"))
  end

  it "preserves the original health URL" do
    get "/health"
    expect(last_response.status).to(eq(200))
  end

  it "supports HEAD without returning a body" do
    head "/health/live"
    expect(last_response.status).to(eq(200))
    expect(last_response.body).to(eq(""))
  end

  it "reports Redis readiness" do
    redis = double("Redis")
    allow(Sidekiq).to(receive(:redis).and_yield(redis))
    expect(redis).to(receive(:call).with("PING").and_return("PONG"))
    get "/health/ready"
    expect(last_response.status).to(eq(200))
    expect(json_body["checks"]).to(eq("redis" => "ok"))
  end

  it "returns 503 when Redis is unavailable without exposing connection details" do
    allow(Sidekiq).to(receive(:redis).and_raise(RedisClient::CannotConnectError, "secret-redis-url"))
    get "/health/ready"
    expect(last_response.status).to(eq(503))
    expect(json_body["checks"]).to(eq("redis" => "unavailable"))
    expect(last_response.body + log_output.string).not_to(include("secret-redis-url"))
  end

  it "requires an API key on application endpoints" do
    get "/examples"
    expect(last_response.status).to(eq(401))
    expect(json_body["errors"].first["code"]).to(eq("API_KEY_ERROR"))
  end

  it "omits the body of HEAD error responses" do
    head "/examples"
    expect(last_response.status).to(eq(401))
    expect(last_response.body).to(eq(""))
  end

  it "rejects incorrect and legacy Base64 API keys" do
    ["wrong", [settings.api_key].pack("m0")].each do |key|
      header "Api-Key", key
      get "/examples"
      expect(last_response.status).to(eq(401))
    end
  end

  it "accepts a valid API key" do
    authorize_api
    get "/examples"
    expect(last_response.status).to(eq(200))
    expect(json_body).to(eq("message" => "Hello"))
    expect(last_response.headers["cache-control"]).to(eq("no-store"))
  end

  it "validates input without returning or logging the password" do
    authorize_api
    header "Content-Type", "application/json"
    post "/examples/validate", JSON.generate(email: "user@example.com", password: "sensitive-example")
    expect(last_response.status).to(eq(200))
    expect(json_body).to(eq("email" => "user@example.com", "valid" => true))
    expect(last_response.body + log_output.string).not_to(include("sensitive-example", settings.api_key))
  end

  it "returns field errors for invalid email and missing password" do
    authorize_api
    header "Content-Type", "application/json"
    post "/examples/validate", JSON.generate(email: "not-an-email")
    expect(last_response.status).to(eq(422))
    expect(json_body["errors"].map { |error| error["field"] }).to(contain_exactly("email", "password"))
  end

  it "rejects unknown fields" do
    authorize_api
    header "Content-Type", "application/json"
    post "/examples/validate", JSON.generate(email: "user@example.com", password: "example", admin: true)
    expect(last_response.status).to(eq(422))
    expect(json_body["errors"].first["field"]).to(eq("admin"))
  end

  it "rejects malformed JSON without logging its contents" do
    authorize_api
    header "Content-Type", "application/json"
    expect do
      post "/examples/validate", '{"password":"never-log-this",'
    end.not_to(output(/never-log-this/).to_stderr)
    expect(last_response.status).to(eq(400))
    expect(last_response.body + log_output.string).not_to(include("never-log-this"))
  end

  it "requires a JSON object" do
    authorize_api
    header "Content-Type", "application/json"
    post "/examples/validate", "[]"
    expect(last_response.status).to(eq(400))
  end

  it "rejects unsupported content types" do
    authorize_api
    post "/examples/validate", "password=example"
    expect(last_response.status).to(eq(415))
  end

  it "limits the size of request bodies" do
    authorize_api
    header "Content-Type", "application/json"
    post "/examples/validate", "x" * (settings.max_request_bytes + 1)
    expect(last_response.status).to(eq(413))
  end

  it "returns JSON 404 for removed sign-in and unknown routes" do
    ["/sign_in", "/unknown"].each do |path|
      post path
      expect(last_response.status).to(eq(404))
      expect(json_body["errors"].first["code"]).to(eq("NOT_FOUND_ERROR"))
    end
  end

  it "accepts preflight requests from configured origins without authentication" do
    options "/examples/validate", {}, "HTTP_ORIGIN" => "https://client.example",
      "HTTP_ACCESS_CONTROL_REQUEST_METHOD" => "POST", "HTTP_ACCESS_CONTROL_REQUEST_HEADERS" => "api-key,content-type"
    expect(last_response.status).to(eq(200))
    expect(last_response.headers["access-control-allow-origin"]).to(eq("https://client.example"))
  end

  it "does not grant CORS access to other origins" do
    get "/health", {}, "HTTP_ORIGIN" => "https://untrusted.example"
    expect(last_response.headers).not_to(have_key("access-control-allow-origin"))
  end

  it "correlates responses and structured logs without logging query strings" do
    header "X-Request-ID", "request-123"
    get "/health?token=never-log-this"
    expect(last_response.headers["x-request-id"]).to(eq("request-123"))
    event = JSON.parse(log_output.string.lines.last)
    expect(event).to(include("event" => "http_request", "request_id" => "request-123", "status" => 200))
    expect(event["duration_ms"]).to(be >= 0)
    expect(log_output.string).not_to(include("never-log-this"))
  end

  [RuntimeError, ArgumentError].each do |error_class|
    it "returns 500 for unexpected #{error_class} without exposing its message" do
      service = instance_double(ValidateExample)
      allow(ValidateExample).to(receive(:new).and_return(service))
      allow(service).to(receive(:call).and_raise(error_class, "secret-in-error-message"))
      authorize_api
      header "Content-Type", "application/json"
      post "/examples/validate", "{}"
      expect(last_response.status).to(eq(500))
      expect(json_body["errors"].first["code"]).to(eq("INTERNAL_SERVER_ERROR"))
      expect(last_response.body + log_output.string).not_to(include("secret-in-error-message"))
      expect(json_body["request_id"]).to(eq(last_response.headers["x-request-id"]))
      expect(log_output.string).to(include('"event":"http_error"'))
    end
  end
end
