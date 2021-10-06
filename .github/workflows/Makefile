STACK_NAME=%
.DEFAULT_GOAL := explain
.PHONY: explain
explain:
	###
	#
	# Welcome to the AWS Infrastructure Templates repo
	#
	##
	@cat Makefile* | grep -E '^[a-zA-Z_-]+:.*?## .*$$' | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: install-hooks
install-hooks: ## Install all the git hooks locally
	pre-commit install

.PHONY: remove-hooks
remove-hooks: ## Delete all the git hooks locally
	pre-commit uninstall

.PHONY: go_linting
go_linting: ## Runs the linting and vetting checks for golang
	go get golang.org/x/lint/golint
	@echo "-Linting source code"
	cd src && $(MAKE) lint
	@echo "✔ Done"
		
.PHONY: lint
lint: go_linting ## Runs the linting of cloud formation templates && go code

.PHONY: build_go_lambdas
build_go_lambdas: ## Builds the golang lambda source code, use STACK_NAME to only build the resources for a specific stack
	@echo "-Building golang code"
	cd src && $(MAKE) build STACK_NAME=$(STACK_NAME)
	@echo "✔ Done"

.PHONY: go_test
go_test: ## Runs the golang unit tests
	@echo "-Running golang unit tests"
	cd src && $(MAKE) test_cov
	@echo "✔ Done"

.PHONY: go_security_check
go_security_check: ## Runs Golang security checks using gosec
	@echo "-Running golang security checks"
	cd src && $(MAKE) security_check
	@echo "✔ Done"

.PHONY: install_lint_and_gosec
install_lint_and_gosec: 
	@echo "-Installing golint and gosec"
	cd src && $(MAKE) install

.PHONY: security-check
security-check: ## Inspect code for security vulnerabilities
	go get github.com/securego/gosec/cmd/gosec
	cd $$GITHUB_WORKSPACE/src && $$GOPATH/bin/gosec ./...

.PHONY: validate-emis-json
validate-emis-json: ## Validate the emis.json file
	npm run validate-emis-json

.PHONY: go-lint-ci
go-lint-ci: ## Lint the code in the CI
	GO111MODULE=on
	go get -u golang.org/x/lint/golint
	git config --global url."https://$$GITHUB_TOKEN:x-oauth-basic@github.com/".insteadOf "https://github.com/"
	cd $$GITHUB_WORKSPACE/src && $$GOPATH/bin/golint -set_exit_status $(shell go list ./...)

.PHONY: test-ci
test-ci:
	GO111MODULE=on
	git config --global url."https://$$GITHUB_TOKEN:x-oauth-basic@github.com/".insteadOf "https://github.com/"
	cd $$GITHUB_WORKSPACE/src && go test ./... -coverprofile=./../coverage.out

.PHONY: build-ci
build-ci: ## builds the lambdas
	cd $$GITHUB_WORKSPACE/src && make build

.PHONY: sonar
sonar: ## Run the sonar scanner
	npx sonar-scanner -Dsonar.login=${SONAR_TOKEN} -Dsonar.branch.name=${SONAR_BRANCH}

.PHONY: cfn-lint
cfn-lint: ##cloudformation linting
	pip3 install cfn-lint
	which cfn-lint
	cfn-lint infrastructure/**/*.yml --ignore-checks W
	cfn-lint infrastructure/**/**/*.yml --ignore-checks W
	cfn-lint infrastructure/**/**/**/*.yml --ignore-checks W --ignore-templates infrastructure/**/**/**/organisation_service_api_gateway_stack.yml infrastructure/**/**/**/organisation_eventing_stack.yml

.PHONY: swagger-lint
swagger-lint: ## Validate the OpenAPI specifications
	npm run swagger-lint

.PHONY: check-environment
check-environment:
ifeq ($(ENV),)
	@echo "[Error] Please specify a ENV"
	@exit 1;
endif

.PHONY: prepare-environment
prepare-environment: check-environment
ifneq (,$(wildcard config/cfn-${ENV}.json))
	cp config/cfn-${ENV}.json cfn.json
else
	@echo "[Error] cfn-${ENV}.json does not exist"
	@exit 1;
endif