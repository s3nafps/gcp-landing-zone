data "google_project" "this" {
  project_id = var.project_id
}

resource "google_kms_key_ring" "this" {
  project  = var.project_id
  name     = var.key_ring_name
  location = var.location
}

resource "google_kms_crypto_key" "gke_secrets" {
  name            = "gke-secrets"
  key_ring        = google_kms_key_ring.this.id
  purpose         = "ENCRYPT_DECRYPT"
  rotation_period = var.rotation_period

  version_template {
    algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
    protection_level = var.protection_level
  }

  lifecycle {
    prevent_destroy = true
  }
}

# GKE encrypts Kubernetes Secrets in etcd with this key (application-layer
# secrets encryption). Only the GKE service agent may use it.
resource "google_kms_crypto_key_iam_member" "gke_service_agent" {
  crypto_key_id = google_kms_crypto_key.gke_secrets.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${data.google_project.this.number}@container-engine-robot.iam.gserviceaccount.com"
}

resource "google_kms_crypto_key" "artifact_registry" {
  name            = "artifact-registry"
  key_ring        = google_kms_key_ring.this.id
  purpose         = "ENCRYPT_DECRYPT"
  rotation_period = var.rotation_period

  version_template {
    algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
    protection_level = var.protection_level
  }

  lifecycle {
    prevent_destroy = true
  }
}

# The Artifact Registry service agent exists once the API is enabled, which the
# landing-zone module does before this module runs.
resource "google_kms_crypto_key_iam_member" "artifact_registry_service_agent" {
  crypto_key_id = google_kms_crypto_key.artifact_registry.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${data.google_project.this.number}@gcp-sa-artifactregistry.iam.gserviceaccount.com"
}
