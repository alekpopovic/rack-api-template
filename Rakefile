# frozen_string_literal: true

Dir.glob(File.join(__dir__, "tasks", "*.rake")).sort.each { |file| import(file) }
task default: [:check, :lint, :test]
