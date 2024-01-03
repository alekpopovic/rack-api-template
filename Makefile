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
