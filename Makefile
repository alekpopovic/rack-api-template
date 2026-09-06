IMAGE ?= rack-api:local

.PHONY: help setup dev console test lint check build api jobs smoke
help:
	@echo "Targets: setup dev console test lint check build api jobs smoke"

setup:
	./bin/setup

dev:
	./bin/dev

console:
	bundle exec ./bin/console

test:
	bundle exec rspec

lint:
	bundle exec rubocop

check:
	bundle exec ./bin/check
	bundle exec rubocop
	bundle exec rspec

build:
	docker build --build-arg RUBY_VERSION="$$(cat .ruby-version)" -t "$(IMAGE)" .

api:
	docker compose up -d api

jobs:
	docker compose up -d sidekiq

smoke:
	bundle exec ./bin/smoke-image "$(IMAGE)"
