mock_provider "google" {
  mock_resource "google_service_account" {
    defaults = {
      name   = "projects/lz-test-project/serviceAccounts/github-ci@lz-test-project.iam.gserviceaccount.com"
      email  = "github-ci@lz-test-project.iam.gserviceaccount.com"
      member = "serviceAccount:github-ci@lz-test-project.iam.gserviceaccount.com"
    }
  }

  mock_resource "google_iam_workload_identity_pool" {
    defaults = {
      name = "projects/123456789012/locations/global/workloadIdentityPools/github"
    }
  }
}

variables {
  project_id        = "lz-test-project"
  github_repository = "s3nafps/gcp-landing-zone"
  project_roles = {
    "roles/container.viewer" = ["group:viewers@example.com", "user:alice@example.com"]
    "roles/logging.viewer"   = ["group:viewers@example.com"]
  }
}

# apply against the mock provider so computed names (the pool path) are known.
run "github_federation_is_scoped_to_one_repository" {
  command = apply

  assert {
    condition     = google_iam_workload_identity_pool_provider.github[0].attribute_condition == "assertion.repository == 's3nafps/gcp-landing-zone' && (assertion.sub == 'repo:s3nafps/gcp-landing-zone:ref:refs/heads/main' || assertion.sub == 'repo:s3nafps/gcp-landing-zone:pull_request')"
    error_message = "Only main-branch and pull request tokens from the configured repository may be accepted."
  }

  assert {
    condition     = google_iam_workload_identity_pool_provider.github[0].oidc[0].issuer_uri == "https://token.actions.githubusercontent.com"
    error_message = "The provider must trust GitHub's OIDC issuer."
  }

  assert {
    condition     = keys(google_service_account_iam_member.deploy_workload_identity) == ["repo:s3nafps/gcp-landing-zone:ref:refs/heads/main"]
    error_message = "Only the main branch may impersonate the deploy account."
  }

  assert {
    condition     = endswith(google_service_account_iam_member.plan_workload_identity[0].member, "/subject/repo:s3nafps/gcp-landing-zone:pull_request")
    error_message = "Pull requests must only reach the read-only plan account."
  }

  assert {
    condition     = alltrue([for r in keys(google_project_iam_member.deploy) : !contains(["roles/owner", "roles/editor"], r)])
    error_message = "The deploy account must not hold primitive roles."
  }
}

run "bindings_are_flattened_per_member" {
  command = plan

  assert {
    condition     = length(google_project_iam_member.this) == 3
    error_message = "Each role and member pair must become one additive binding."
  }
}

run "nothing_federated_without_a_repository" {
  command = plan

  variables {
    github_repository = null
  }

  assert {
    condition     = length(google_iam_workload_identity_pool.github) == 0 && length(google_service_account.deploy) == 0 && length(google_service_account.plan) == 0
    error_message = "Federation resources must only exist when a repository is set."
  }
}

run "rejects_owner_grants" {
  command = plan

  variables {
    project_roles = { "roles/owner" = ["user:alice@example.com"] }
  }

  expect_failures = [var.project_roles]
}

run "rejects_members_without_a_type_prefix" {
  command = plan

  variables {
    project_roles = { "roles/viewer" = ["alice@example.com"] }
  }

  expect_failures = [var.project_roles]
}

run "rejects_a_malformed_repository" {
  command = plan

  variables {
    github_repository = "not a repo"
  }

  expect_failures = [var.github_repository]
}

run "pull_request_plans_can_be_disabled" {
  command = plan

  variables {
    allow_pull_request_plans = false
  }

  assert {
    condition     = length(google_service_account.plan) == 0 && !strcontains(google_iam_workload_identity_pool_provider.github[0].attribute_condition, "pull_request")
    error_message = "With plans disabled, pull request tokens must be rejected outright."
  }
}

run "rejects_wildcard_deploy_refs" {
  command = plan

  variables {
    github_deploy_refs = ["refs/heads/*"]
  }

  expect_failures = [var.github_deploy_refs]
}

run "rejects_write_roles_on_the_plan_account" {
  command = plan

  variables {
    ci_plan_roles = ["roles/container.admin"]
  }

  expect_failures = [var.ci_plan_roles]
}
