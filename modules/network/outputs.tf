output "network_id" {
  description = "ID of the VPC."
  value       = google_compute_network.this.id
}

output "network_self_link" {
  description = "Self link of the VPC."
  value       = google_compute_network.this.self_link
}

output "subnet_id" {
  description = "ID of the GKE subnet."
  value       = google_compute_subnetwork.gke.id
}

output "subnet_self_link" {
  description = "Self link of the GKE subnet."
  value       = google_compute_subnetwork.gke.self_link
}

output "pods_range_name" {
  description = "Name of the secondary range for pods."
  value       = google_compute_subnetwork.gke.secondary_ip_range[0].range_name
}

output "services_range_name" {
  description = "Name of the secondary range for services."
  value       = google_compute_subnetwork.gke.secondary_ip_range[1].range_name
}
