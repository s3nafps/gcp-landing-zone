output "network_id" {
  description = "VPC ID."
  value       = module.network.network_id
}

output "cluster_name" {
  description = "GKE cluster name."
  value       = module.gke.cluster_name
}

output "get_credentials_command" {
  description = "Configure kubectl for the cluster."
  value       = module.gke.get_credentials_command
}

output "workload_identity_pool" {
  description = "Workload Identity pool for Kubernetes service accounts."
  value       = module.gke.workload_identity_pool
}

output "registry_url" {
  description = "Artifact Registry Docker repository."
  value       = module.registry.repository_url
}

output "github_workload_identity_provider" {
  description = "workload_identity_provider for google-github-actions/auth."
  value       = module.iam.workload_identity_provider
}

output "github_deploy_service_account" {
  description = "service_account for workflows on the deploy branches."
  value       = module.iam.deploy_service_account_email
}

output "github_plan_service_account" {
  description = "service_account for pull request plan workflows (read-only)."
  value       = module.iam.plan_service_account_email
}
