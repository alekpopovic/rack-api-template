ARG RUBY_VERSION=3.3.2
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim as base

WORKDIR /rack

ENV RACK_ENV="production" \
  BUNDLE_DEPLOYMENT="1" \
  BUNDLE_PATH="/usr/local/bundle" \
  BUNDLE_WITHOUT="development" \
  MAX_THREADS="5" \
  MIN_THREADS="5" \
  PORT="3000"

FROM base as build

RUN apt-get update -qq && \
  apt-get install --no-install-recommends -y \
  build-essential \
  curl \
  git \
  libpq-dev \
  libvips \
  pkg-config \
  python-is-python3 \
  libjemalloc2

COPY Gemfile Gemfile.lock ./

RUN bundle install && \
  rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

COPY . .

FROM base

RUN apt-get update -qq && \
  apt-get install --no-install-recommends -y curl libvips postgresql-client && \
  rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rack /rack
