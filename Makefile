export DOCKER_DB_NAME=go_graphql_api
export DOCKER_DB_USER=postgres
export DOCKER_DB_PASS=mysecretpassword
export DOCKER_DB_PORT=5432
export DOCKER_DB_HOST=127.0.0.1
export DATABASE_URL=postgres://${DOCKER_DB_USER}:${DOCKER_DB_PASS}@${DOCKER_DB_HOST}:${DOCKER_DB_PORT}/${DOCKER_DB_NAME}



define image-run
	docker run \
		--rm \
		--name $(DOCKER_DB_NAME) \
		-e POSTGRES_USER=$(DOCKER_DB_USER) \
		-e POSTGRES_PASSWORD=$(DOCKER_DB_PASS) \
		-e POSTGRES_DB=$(DOCKER_DB_NAME) \
		-p $(DOCKER_DB_PORT):5432 \
		-d postgres
endef

define psql-exec
	docker exec $(DOCKER_DB_NAME) psql $(DATABASE_URL) -c '$(1)'
endef

define psql-file
	docker exec $(DOCKER_DB_NAME) psql $(DATABASE_URL) < '$(1)';
endef

.PHONY: default
default: help

.PHONY: help
help: ## help information about make commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: db-up
db-up: ## start the database server (local)
	$(call image-run)

.PHONY: db-stop
db-stop: ## stop the database server (local)
	docker container stop $(DOCKER_DB_NAME)

.PHONY: testdata
testdata: ## populate the database with test data
# 	# $(call psql-exec,DROP SCHEMA IF EXISTS public CASCADE)
# 	# $(call psql-exec,CREATE SCHEMA public)
	$(call psql-exec,CREATE DATABASE "go_graphql_db")
# 	# $(call psql-file, < ./migrations/init.sql)
	# cat ./migrations/init.sql | docker exec ${DOCKER_DB_NAME} psql ${DATABASE_URL} -1

# .PHONY: testdata
# testdata: ## populate the database with test data
# 	@echo "Populating test data..."
# 	psql < migrations/init.sql;