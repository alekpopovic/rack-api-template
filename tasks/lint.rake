# frozen_string_literal: true

task :lint do
  bundle exec("rubocop")
end
