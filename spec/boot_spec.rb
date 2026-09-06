# frozen_string_literal: true

require "open3"
require "tmpdir"
require "fileutils"

RSpec.describe("Application setup and boot") do
  it "generates local secrets once without printing or replacing them" do
    Dir.mktmpdir("rack-api-setup") do |directory|
      FileUtils.mkdir_p(File.join(directory, "bin"))
      FileUtils.cp(File.join(RackApi::ROOT, "bin/setup"), File.join(directory, "bin/setup"))
      FileUtils.cp(File.join(RackApi::ROOT, ".env.example"), directory)
      output, status = Open3.capture2(RbConfig.ruby, File.join(directory, "bin/setup"), "--env-only")
      expect(status).to(be_success)
      path = File.join(directory, ".env")
      original = File.read(path)
      api_key = original[/^CLIENT_API_KEY=(.+)$/, 1]
      session_secret = original[/^SIDEKIQ_WEB_SESSION_SECRET=(.+)$/, 1]
      expect(api_key.length).to(be >= 64)
      expect(session_secret.length).to(be >= 64)
      expect(output).not_to(include(api_key, session_secret))
      expect(File.stat(path).mode & 0o777).to(eq(0o600))
      _, status = Open3.capture2(RbConfig.ruby, File.join(directory, "bin/setup"), "--env-only")
      expect(status).to(be_success)
      expect(File.read(path)).to(eq(original))
    end
  end

  it "boots application classes from outside the repository" do
    output, error, status = Open3.capture3({ "BUNDLE_GEMFILE" => nil, "RACK_ENV" => "test" },
      RbConfig.ruby, File.join(RackApi::ROOT, "bin/check"), chdir: Dir.tmpdir)
    expect(status.success?).to(be(true), error)
    expect(output).to(include("Application classes loaded successfully"))
  end

  it "disables the sample recurring job in production without HTTP secrets" do
    script = <<~RUBY_CODE
      require "sidekiq/cli"
      cli = Sidekiq::CLI.instance
      cli.parse(["-r", "./config/sidekiq.rb", "-C", "config/sidekiq.yml"])
      cli.send(:boot_application)
      abort "Example job is enabled" if Sidekiq.default_configuration[:scheduler][:schedule].key?("hello_world")
      abort "Wrong concurrency" unless Sidekiq.default_configuration.concurrency == 3
    RUBY_CODE
    _, error, status = Open3.capture3({ "RACK_ENV" => "production", "ENABLE_EXAMPLE_JOBS" => nil,
      "CLIENT_API_KEY" => nil, "SIDEKIQ_WEB_ENABLED" => nil, "SIDEKIQ_CONCURRENCY" => "3" },
      RbConfig.ruby, "-e", script, chdir: RackApi::ROOT)
    expect(status.success?).to(be(true), error)
  end

  it "includes job identity in structured log events" do
    output = StringIO.new
    logger = RackApi::Logging.build(settings_for, output: output)
    Sidekiq::Context.with(jid: "example-jid", class: "HelloJob", elapsed: 0.1) { logger.info("done") }
    expect(JSON.parse(output.string)).to(include("jid" => "example-jid", "class" => "HelloJob", "elapsed" => 0.1))
  end
end
