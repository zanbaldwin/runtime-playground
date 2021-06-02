SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.ONESHELL:
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules
ifeq ($(origin .RECIPEPREFIX), undefined)
  $(error This Make does not support .RECIPEPREFIX; Please use GNU Make 4.0 or later)
endif
.RECIPEPREFIX = >

THIS_MAKEFILE_PATH:=$(word $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST))
THIS_DIR:=$(shell cd $(dir $(THIS_MAKEFILE_PATH));pwd)
THIS_MAKEFILE:=$(notdir $(THIS_MAKEFILE_PATH))

usage:
> @grep -E '(^[a-zA-Z_-]+:\s*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.?## "}; {printf "\033[32m %-30s\033[0m%s\n", $$1, $$2}' | sed -e 's/\[32m ## /[33m/'
.PHONY: usage
.SILENT: usage

mock-ssl: ## Mocks an SSL Certificate for Development
mock-ssl:
> command -v "mkcert" >/dev/null 2>&1 || { echo >&2 "Please install MkCert for Development."; exit 1; }
> export $$(echo "$$(cat "$(THIS_DIR)/.env" | sed 's/#.*//g'| xargs)")
> [ -z "$${DOMAIN}" ] && { echo >&2 "Could not determine domain from environment file."; exit 1; }
> mkdir -p "$(THIS_DIR)/build/ssl/challenges"
> mkdir -p "$(THIS_DIR)/build/ssl/live/docker"
> (cd "$(THIS_DIR)/build/ssl"; mkcert "localhost" "$${DOMAIN}" "127.0.0.1")
> mv "$(THIS_DIR)/build/ssl/localhost+2.pem" "$(THIS_DIR)/build/ssl/live/docker/fullchain.pem"
> cp "$(THIS_DIR)/build/ssl/live/docker/fullchain.pem" "$(THIS_DIR)/build/ssl/live/docker/chain.pem"
> mv "$(THIS_DIR)/build/ssl/localhost+2-key.pem" "$(THIS_DIR)/build/ssl/live/docker/privkey.pem"
> openssl dhparam -out "$(THIS_DIR)/build/ssl/dhparam.pem" 512
> echo >&2 "Check that $$(tput setaf 2)$${DOMAIN}$$(tput sgr0) has been added to \"/etc/hosts\" (add the line \"127.0.0.1 $${DOMAIN}\")."
.PHONY: mock-ssl
.SILENT: mock-ssl

password: ## Generates a secure, random password for the database
password:
> mkdir -p "$(THIS_DIR)/build/.secrets"
> [ ! -f "$(THIS_DIR)/build/.secrets/dbpass" ] || { \
    echo >&2 "$$(tput setaf 1)A password has already been created. Remove the file \"$(THIS_DIR)/build/.secrets/dbpass\" to try again.$$(tput sgr0)"; \
    echo >&2 "$$(tput setaf 1)Double check that you're NOT REMOVING THE ONLY COPY OF YOUR EXISTING PASSWORD.$$(tput sgr0)"; \
    exit 1; \
}
> echo "$$(date "+%s.%N" | sha256sum | base64 | head -c 40)" > "$(THIS_DIR)/build/.secrets/dbpass"
> echo >&2 "$$(tput setaf 2)Database password generated and placed in file \"$(THIS_DIR)/build/.secrets/dbpass\".$$(tput sgr0)"
.PHONY: password
.SILENT: password
