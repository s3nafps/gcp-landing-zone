output "workload_identity_provider" {
  description = "Value for the workload_identity_provider input of google-github-actions/auth."
  value       = var.github_repository == null ? null : google_iam_workload_identity_pool_provider.github[0].name
}

output "deploy_service_account_email" {
  description = "service_account for workflows on the deploy branches."
  value       = var.github_repository == null ? null : google_service_account.deploy[0].email
}

output "plan_service_account_email" {
  description = "service_account for pull request plan workflows."
  value       = var.github_repository == null || !var.allow_pull_request_plans ? null : google_service_account.plan[0].email
}
