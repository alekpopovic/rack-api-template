# frozen_string_literal: true

desc "Run the test suite"
task :test do
  sh "bundle", "exec", "rspec"
end

desc "Load every application class"
task :check do
  sh "bundle", "exec", "ruby", "bin/check"
end
