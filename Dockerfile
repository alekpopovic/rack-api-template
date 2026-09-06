ARG RUBY_VERSION=4.0.5
FROM ruby:${RUBY_VERSION}-slim AS base

WORKDIR /rack
ENV RACK_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test" \
    PORT="3000"

FROM base AS build
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential && \
    rm -rf /var/lib/apt/lists/*
COPY Gemfile Gemfile.lock .ruby-version ./
RUN bundle install && \
    rm -rf /usr/local/bundle/ruby/*/cache /usr/local/bundle/ruby/*/bundler/gems/*/.git
COPY . .

FROM base AS production
RUN groupadd --gid 10001 app && \
    useradd --uid 10001 --gid app --home-dir /rack --no-create-home app && \
    ruby -rrubygems/uninstaller -e 'Gem::Uninstaller.new("debug", all: true, ignore: true, executables: true, install_dir: Gem.default_dir).uninstall'
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build --chown=app:app /rack /rack
USER app:app
EXPOSE 3000
STOPSIGNAL SIGTERM
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
