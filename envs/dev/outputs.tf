output "cluster_name" {
  description = "GKE cluster name."
  value       = module.landing_zone.cluster_name
}

output "get_credentials_command" {
  description = "Configure kubectl for the cluster."
  value       = module.landing_zone.get_credentials_command
}

output "registry_url" {
  description = "Artifact Registry Docker repository."
  value       = module.landing_zone.registry_url
}

output "github_workload_identity_provider" {
  description = "workload_identity_provider for google-github-actions/auth."
  value       = module.landing_zone.github_workload_identity_provider
}

output "github_deploy_service_account" {
  description = "service_account for workflows on the deploy branches."
  value       = module.landing_zone.github_deploy_service_account
}

output "github_plan_service_account" {
  description = "service_account for pull request plan workflows (read-only)."
  value       = module.landing_zone.github_plan_service_account
}
