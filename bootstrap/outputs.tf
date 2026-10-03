output "state_bucket" {
  description = "Pass to terraform init -backend-config=\"bucket=...\" in each environment."
  value       = google_storage_bucket.state.name
}
