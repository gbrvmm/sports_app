SHELL := /bin/bash

PGHOST ?= 127.0.0.1
PGPORT ?= 5432
PGDATABASE ?= sportsdb
PGUSER ?= postgres
PGPASSWORD ?= postgres

PGSUPERUSER ?= postgres
PGSUPERDB ?= postgres
PGSUPERPASS ?=

export PGHOST PGPORT PGDATABASE PGUSER PGPASSWORD

psql-super = PGPASSWORD=$(PGSUPERPASS) psql -h $(PGHOST) -p $(PGPORT) -U $(PGSUPERUSER) -d $(PGSUPERDB) -v ON_ERROR_STOP=1
psql-user  = PGPASSWORD=$(PGPASSWORD)  psql -h $(PGHOST) -p $(PGPORT) -U $(PGUSER)  -d $(PGDATABASE) -v ON_ERROR_STOP=1

.PHONY: help db-create migrate seed run tidy build

help:
	@echo "make db-create   # create db and user (as superuser)"
	@echo "make migrate     # apply schema.sql"
	@echo "make seed        # load demo.sql"
	@echo "make run         # run Go server on :8080"
	@echo "make tidy/build  # go tidy/build"

db-create:
	@$(psql-super) -c "DO $$ BEGIN IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '$(PGUSER)') THEN CREATE USER $(PGUSER) WITH PASSWORD '$(PGPASSWORD)'; END IF; END $$;"
	@$(psql-super) -c "DO $$ BEGIN IF NOT EXISTS (SELECT FROM pg_database WHERE datname = '$(PGDATABASE)') THEN CREATE DATABASE $(PGDATABASE); END IF; END $$;"
	@$(psql-super) -d $(PGDATABASE) -c "GRANT ALL PRIVILEGES ON DATABASE $(PGDATABASE) TO $(PGUSER);"
	@$(psql-super) -d $(PGDATABASE) -c "ALTER SCHEMA public OWNER TO $(PGUSER);"

migrate:
	@$(psql-user) -f schema.sql

seed:
	@$(psql-user) -f demo.sql

run:
	@DATABASE_URL=$${DATABASE_URL:-postgres://$(PGUSER):$(PGPASSWORD)@$(PGHOST):$(PGPORT)/$(PGDATABASE)?sslmode=disable} \
	go run ./cmd/server

tidy:
	@go mod tidy

build:
	@go build -o bin/server ./cmd/server
