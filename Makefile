-include .env

SHELL = bash
PKG = github.com/pprishchepa/deploy-app-example

VERSION ?= dev
SHORT_COMMIT ?=

GOOS ?= linux
GOARCH ?= amd64
GOPATH ?= $(go env GOPATH)

MAKE = $(shell which make)

PROJECT_ENV ?=
PROJECT_NAME ?=
PROJECT_DATA ?=
ifeq ($(CI),true)
	PROJECT_ENV = ci
endif

default: build

build:
	CGO_ENABLED=0 go build -trimpath -o ./build/myapp/myapp $(PKG)/cmd/myapp
.PHONY: build

lint:
	$(GOPATH)/bin/golangci-lint run -v ./...
.PHONY: lint

test:
	go test -v ./...
.PHONY: test

fmt:
	find . -name '*.go' | while read -r file; do '$(GOPATH)/bin/goimports' -w "$$file"; done
.PHONY: fmt

mod:
	go mod tidy
	go mod download
.PHONY: mod

ci: fmt mod build lint test
.PHONY: ci

up: check_env
ifeq ($(wildcard $(PROJECT_DATA)),)
	$(MAKE) setup
endif
	docker-compose up -d --build --remove-orphans --force-recreate
.PHONY: up

down: check_env
	docker-compose down --remove-orphans  --volumes
.PHONY: down

stop: check_env
	docker-compose stop
.PHONY: stop

setup: check_env
ifneq ($(PROJECT_ENV),local)
	$(error the target permitted in local environment only)
endif
.PHONY: setup

logs: check_env
	docker-compose logs -f --tail 50
.PHONY: logs

check_env:
ifeq ($(PROJECT_ENV),)
	$(error PROJECT_ENV is not defined)
endif
ifeq ($(PROJECT_NAME),)
	$(error PROJECT_NAME is not defined)
endif
ifeq ($(PROJECT_DATA),)
	$(error PROJECT_DATA is not defined)
endif
.PHONY: check_env