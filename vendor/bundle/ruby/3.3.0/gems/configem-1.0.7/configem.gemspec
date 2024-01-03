# frozen_string_literal: true

require_relative "./lib/configem"

Gem::Specification.new do |spec|
  spec.name = "configem"
  spec.version = Configem::VERSION
  spec.authors = ["Aleksandar Popovic"]
  spec.email = ["aleksandar.popovic@linux.com"]
  spec.summary = "A mixin to add configuration functionality"
  spec.description = "A mixin to add configuration functionality to your classes"
  spec.homepage = "https://github.com/alekpopovic/configem"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/alekpopovic/configem"
  spec.metadata["changelog_uri"] = "https://github.com/alekpopovic/configem/blob/main/CHANGELOG.md"
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
