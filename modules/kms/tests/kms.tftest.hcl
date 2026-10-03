mock_provider "google" {
  mock_data "google_project" {
    defaults = {
      number = "123456789012"
    }
  }
}

variables {
  project_id    = "lz-test-project"
  location      = "europe-west1"
  key_ring_name = "lz-dev-keyring"
}

run "key_rotates_and_only_gke_can_use_it" {
  command = plan

  assert {
    condition     = google_kms_crypto_key.gke_secrets.rotation_period == "7776000s"
    error_message = "The key must rotate every 90 days."
  }

  assert {
    condition     = google_kms_crypto_key_iam_member.gke_service_agent.member == "serviceAccount:service-123456789012@container-engine-robot.iam.gserviceaccount.com"
    error_message = "Only the GKE service agent may use the key."
  }

  assert {
    condition     = google_kms_crypto_key_iam_member.artifact_registry_service_agent.member == "serviceAccount:service-123456789012@gcp-sa-artifactregistry.iam.gserviceaccount.com"
    error_message = "The Artifact Registry key must be usable by its service agent."
  }
}

run "rejects_rotation_longer_than_90_days" {
  command = plan

  variables {
    rotation_period = "31536000s"
  }

  expect_failures = [var.rotation_period]
}
