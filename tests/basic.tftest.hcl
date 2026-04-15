# Minimal plan-time test: validates that examples/basic plans successfully
# with its default configuration (no Route53, no ACM, no credentials required).
run "basic_example_plans" {
  command = plan

  module {
    source = "./examples/basic"
  }

  variables {
    environment = "dev"
    region      = "us-east-1"
  }
}
