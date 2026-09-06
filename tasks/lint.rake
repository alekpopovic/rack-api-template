# frozen_string_literal: true

desc "Check Ruby style"
task :lint do
  sh "bundle", "exec", "rubocop"
end
