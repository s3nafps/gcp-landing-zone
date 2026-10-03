output "cluster_id" {
  description = "Cluster ID."
  value       = google_container_cluster.this.id
}

output "cluster_name" {
  description = "Cluster name."
  value       = google_container_cluster.this.name
}

output "endpoint" {
  description = "Control plane endpoint."
  value       = google_container_cluster.this.endpoint
  sensitive   = true
}

output "node_service_account" {
  description = "Email of the node service account."
  value       = google_service_account.nodes.email
}

output "workload_identity_pool" {
  description = "Workload Identity pool for Kubernetes service accounts."
  value       = google_container_cluster.this.workload_identity_config[0].workload_pool
}

output "get_credentials_command" {
  description = "Command to configure kubectl."
  value       = "gcloud container clusters get-credentials ${google_container_cluster.this.name} --location ${var.location} --project ${var.project_id}"
}
