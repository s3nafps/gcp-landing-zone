mock_provider "google" {
  mock_data "google_project" {
    defaults = {
      number = "123456789012"
    }
  }
}

variables {
  project_id  = "lz-test-project"
  environment = "dev"
  master_authorized_networks = [
    { cidr_block = "203.0.113.10/32", display_name = "admin-vpn" },
  ]
  github_repository = "s3nafps/gcp-landing-zone"
}

run "dev_plans_a_zonal_cluster" {
  command = plan

  assert {
    condition     = strcontains(output.get_credentials_command, "--location europe-west1-b ")
    error_message = "Dev should run a zonal cluster."
  }

  assert {
    condition     = output.registry_url == "europe-west1-docker.pkg.dev/lz-test-project/containers"
    error_message = "The registry URL must follow the regional Artifact Registry format."
  }

  assert {
    condition     = length(module.budget) == 0
    error_message = "No budget is created without a billing account."
  }
}

run "prod_plans_a_regional_cluster_with_a_budget" {
  command = plan

  variables {
    environment      = "prod"
    regional_cluster = true
    billing_account  = "0A1B2C-3D4E5F-6A7B8C"
  }

  assert {
    condition     = strcontains(output.get_credentials_command, "--location europe-west1 ")
    error_message = "Prod should run a regional cluster."
  }

  assert {
    condition     = length(module.budget) == 1
    error_message = "A budget must be created when a billing account is set."
  }
}

run "rejects_unknown_environments" {
  command = plan

  variables {
    environment = "qa"
  }

  expect_failures = [var.environment]
}
