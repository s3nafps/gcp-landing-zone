locals {
  # Flatten { role = [members] } into one binding per pair. Bindings are additive
  # (google_project_iam_member), so they never remove access granted elsewhere.
  bindings = merge([
    for role, members in var.project_roles : {
      for member in members : "${role}|${member}" => { role = role, member = member }
    }
  ]...)

  federate = var.github_repository != null

  # GitHub's "sub" claim identifies the repository and what triggered the run.
  deploy_subjects  = [for ref in var.github_deploy_refs : "repo:${coalesce(var.github_repository, "none/none")}:ref:${ref}"]
  plan_subject     = "repo:${coalesce(var.github_repository, "none/none")}:pull_request"
  allowed_subjects = concat(local.deploy_subjects, var.allow_pull_request_plans ? [local.plan_subject] : [])

  attribute_condition = join(" && ", [
    "assertion.repository == '${coalesce(var.github_repository, "none/none")}'",
    "(${join(" || ", [for s in local.allowed_subjects : "assertion.sub == '${s}'"])})",
  ])
}

resource "google_project_iam_member" "this" {
  for_each = local.bindings

  project = var.project_id
  role    = each.value.role
  member  = each.value.member
}

# Keyless CI: GitHub Actions exchanges its OIDC token for short-lived Google
# credentials. No service account key is ever created or stored in GitHub.
resource "google_iam_workload_identity_pool" "github" {
  count = local.federate ? 1 : 0

  project                   = var.project_id
  workload_identity_pool_id = var.workload_identity_pool_id
  display_name              = "GitHub Actions"
  description               = "OIDC federation for GitHub Actions workflows."
}

resource "google_iam_workload_identity_pool_provider" "github" {
  #checkov:skip=CKV_GCP_125:The condition pins repository and exact sub claims but is built from variables, which checkov cannot evaluate; tests/iam.tftest.hcl asserts the rendered condition.
  count = local.federate ? 1 : 0

  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github[0].workload_identity_pool_id
  workload_identity_pool_provider_id = "github"
  display_name                       = "GitHub"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
    "attribute.ref"        = "assertion.ref"
    "attribute.actor"      = "assertion.actor"
  }

  # Tokens from any other repository, branch or event are rejected before any IAM check.
  attribute_condition = local.attribute_condition

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# Deploy account: can change infrastructure, and only runs on the deploy branches.
resource "google_service_account" "deploy" {
  count = local.federate ? 1 : 0

  project      = var.project_id
  account_id   = "${var.ci_service_account_prefix}-deploy"
  display_name = "CI deploy for ${var.github_repository}"
}

resource "google_service_account_iam_member" "deploy_workload_identity" {
  for_each = local.federate ? toset(local.deploy_subjects) : toset([])

  service_account_id = google_service_account.deploy[0].name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principal://iam.googleapis.com/${google_iam_workload_identity_pool.github[0].name}/subject/${each.value}"
}

resource "google_project_iam_member" "deploy" {
  for_each = local.federate ? toset(var.ci_deploy_roles) : toset([])

  project = var.project_id
  role    = each.value
  member  = google_service_account.deploy[0].member
}

# Plan account: read-only, used by pull request workflows to run terraform plan.
resource "google_service_account" "plan" {
  count = local.federate && var.allow_pull_request_plans ? 1 : 0

  project      = var.project_id
  account_id   = "${var.ci_service_account_prefix}-plan"
  display_name = "CI plan (read-only) for ${var.github_repository}"
}

resource "google_service_account_iam_member" "plan_workload_identity" {
  count = local.federate && var.allow_pull_request_plans ? 1 : 0

  service_account_id = google_service_account.plan[0].name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principal://iam.googleapis.com/${google_iam_workload_identity_pool.github[0].name}/subject/${local.plan_subject}"
}

resource "google_project_iam_member" "plan" {
  for_each = local.federate && var.allow_pull_request_plans ? toset(var.ci_plan_roles) : toset([])

  project = var.project_id
  role    = each.value
  member  = google_service_account.plan[0].member
}
