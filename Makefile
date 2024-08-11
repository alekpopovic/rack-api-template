.PHONY: help
help:
	@echo 'Usage:'
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' |  sed -e 's/^/ /'

.PHONY: confirm
confirm:
	@echo -n 'Are you sure? [y/N] ' && read ans && [ $${ans:-N} = y ]

.PHONY: setup
setup:
	./bin/setup

.PHONY: dev
dev:
	./bin/dev

.PHONY: console
console:
	./bin/console

.PHONY: test
test:
	rspec

.PHONY: lint
lint:
	rubocop

## build: docker build
.PHONY: build
build:
	docker build -t rack-api:0.0.1 .

## api: start api
.PHONY: api
api:
	docker run --rm -it --network host --env-file .env -p 3000:3000/tcp --name rack-api rack-api:0.0.1 bundle exec puma

## jobs: start jobs
.PHONY: jobs
jobs:
	docker run --rm -it --network host --env-file .env --name rack-api-sidekik rack-api:0.0.1 bundle exec sidekiq -r ./config/sidekiq.rb -C config/sidekiq.yml
