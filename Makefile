.PHONY: fmt validate lint test plan clean

# Default AWS region for plan/validate (override: make plan AWS_REGION=us-west-2)
AWS_REGION ?= us-east-1

fmt:
	terraform fmt -recursive -check

fmt-fix:
	terraform fmt -recursive

validate:
	terraform -chdir=examples/basic init -backend=false -upgrade
	terraform -chdir=examples/basic validate
	terraform -chdir=examples/complete init -backend=false -upgrade
	terraform -chdir=examples/complete validate

lint:
	@command -v tflint >/dev/null 2>&1 || { echo "tflint not installed; see https://github.com/terraform-linters/tflint"; exit 1; }
	tflint --init
	tflint --recursive

test:
	terraform test

plan:
	terraform -chdir=examples/basic init -upgrade
	terraform -chdir=examples/basic plan

clean:
	find . -type d -name .terraform -prune -exec rm -rf {} +
	find . -type f -name .terraform.lock.hcl -delete
