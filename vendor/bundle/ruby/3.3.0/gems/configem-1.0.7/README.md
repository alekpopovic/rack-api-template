# Configem

[![Ruby](https://github.com/alekpopovic/configem/actions/workflows/ruby.yml/badge.svg)](https://github.com/alekpopovic/configem/actions/workflows/ruby.yml)

[![Ruby Gem](https://github.com/alekpopovic/configem/actions/workflows/gem-push.yml/badge.svg)](https://github.com/alekpopovic/configem/actions/workflows/gem-push.yml)

A simple mixin to add configuration functionality to your classes

## Installation

TODO: Replace `UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG` with your gem name right after releasing it to RubyGems.org. Please do not do it earlier due to security reasons. Alternatively, replace this section with instructions to install your gem from git if you don't plan to release to RubyGems.org.

Install the gem and add to the application's Gemfile by executing:

    $ bundle add configem

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install configem

## Usage

```sh
class Example1
  include Configem
end

class Example2
  extend Configem
end

class Example3
  prepend Configem
end

Example1.configure do |config|
  config.api_key_1 = "api_key_1_value"
end

Example2.configure do |config|
  config.api_key_2 = "api_key_2_value"
end

Example3.configure do |config|
  config.api_key_3 = "api_key_3_value"
end

puts Example1.config.api_key_1

puts Example2.config.api_key_2

puts Example3.config.api_key_3
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/alekpopovic/configem/issues. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/alekpopovic/configem/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Configem project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/alekpopovic/configem/blob/master/CODE_OF_CONDUCT.md).
