ROOTS   := bootstrap envs/dev envs/prod
MODULES := $(wildcard modules/*)
ENV     ?= dev

.PHONY: help fmt validate test lint security docs check plan apply

help: ## Show targets
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  %-10s %s\n", $$1, $$2}'

fmt: ## Format all Terraform files
	terraform fmt -recursive

validate: ## Validate every root configuration (no backend, no credentials)
	@for d in $(ROOTS); do echo "==> $$d"; terraform -chdir=$$d init -backend=false -input=false >/dev/null && terraform -chdir=$$d validate || exit 1; done

test: ## Run terraform test in every module that has tests (mock provider, no credentials)
	@for m in $(MODULES); do if [ -d $$m/tests ]; then echo "==> $$m"; terraform -chdir=$$m init -backend=false -input=false >/dev/null && terraform -chdir=$$m test || exit 1; fi; done

lint: ## tflint with the Google ruleset
	tflint --init
	tflint --recursive

security: ## checkov static analysis
	checkov -d . --config-file .checkov.yml

docs: ## Regenerate module READMEs
	@for m in $(MODULES); do terraform-docs -c .terraform-docs.yml $$m >/dev/null; done

check: fmt validate test lint security ## Everything CI runs

plan: ## terraform plan for ENV (needs credentials and a state bucket)
	terraform -chdir=envs/$(ENV) plan

apply: ## terraform apply for ENV
	terraform -chdir=envs/$(ENV) apply
