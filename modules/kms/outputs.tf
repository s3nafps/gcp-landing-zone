output "gke_secrets_key_id" {
  description = "ID of the key used for GKE application-layer secrets encryption."
  value       = google_kms_crypto_key.gke_secrets.id
}

output "gke_key_iam_ready" {
  description = "Resolves after the GKE service agent can use the key; use in depends_on."
  value       = google_kms_crypto_key_iam_member.gke_service_agent.id
}

output "artifact_registry_key_id" {
  description = "ID of the key that encrypts the Artifact Registry repository."
  value       = google_kms_crypto_key.artifact_registry.id
}

output "artifact_registry_key_iam_ready" {
  description = "Resolves after the Artifact Registry service agent can use the key; use in depends_on."
  value       = google_kms_crypto_key_iam_member.artifact_registry_service_agent.id
}
