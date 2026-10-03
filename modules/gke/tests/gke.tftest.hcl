mock_provider "google" {}

variables {
  project_id             = "lz-test-project"
  name                   = "lz-dev"
  location               = "europe-west1-b"
  network_self_link      = "projects/lz-test-project/global/networks/lz-dev"
  subnet_self_link       = "projects/lz-test-project/regions/europe-west1/subnetworks/lz-dev-gke"
  pods_range_name        = "pods"
  services_range_name    = "services"
  master_ipv4_cidr_block = "172.16.0.0/28"
  master_authorized_networks = [
    { cidr_block = "203.0.113.10/32", display_name = "admin-vpn" },
  ]
  secrets_encryption_key_id = "projects/lz-test-project/locations/europe-west1/keyRings/lz-dev-keyring/cryptoKeys/gke-secrets"
}

run "control_plane_is_private_and_hardened" {
  command = plan

  assert {
    condition     = google_container_cluster.this.private_cluster_config[0].enable_private_nodes
    error_message = "Nodes must not have public IPs."
  }

  assert {
    condition     = google_container_cluster.this.master_authorized_networks_config[0].gcp_public_cidrs_access_enabled == false
    error_message = "The control plane must not be reachable from all Google Cloud IPs."
  }

  assert {
    condition     = google_container_cluster.this.enable_legacy_abac == false
    error_message = "Legacy ABAC must be disabled."
  }

  assert {
    condition     = google_container_cluster.this.enable_shielded_nodes
    error_message = "Shielded nodes must be enabled."
  }

  assert {
    condition     = google_container_cluster.this.datapath_provider == "ADVANCED_DATAPATH"
    error_message = "Dataplane V2 must be enabled so NetworkPolicy is enforced."
  }

  assert {
    condition     = google_container_cluster.this.workload_identity_config[0].workload_pool == "lz-test-project.svc.id.goog"
    error_message = "Workload Identity must be enabled."
  }

  assert {
    condition     = google_container_cluster.this.database_encryption[0].state == "ENCRYPTED"
    error_message = "Kubernetes Secrets must be encrypted with the KMS key."
  }

  assert {
    condition     = google_container_cluster.this.remove_default_node_pool
    error_message = "The default node pool must be removed in favour of the managed pool."
  }
}

run "node_pool_follows_least_privilege" {
  command = plan

  assert {
    condition     = google_container_node_pool.default.node_config[0].workload_metadata_config[0].mode == "GKE_METADATA"
    error_message = "Pods must use the GKE metadata server, not the node's credentials."
  }

  assert {
    condition     = google_container_node_pool.default.node_config[0].metadata["disable-legacy-endpoints"] == "true"
    error_message = "Legacy metadata endpoints must be disabled."
  }

  assert {
    condition     = google_container_node_pool.default.node_config[0].shielded_instance_config[0].enable_secure_boot
    error_message = "Secure Boot must be enabled on nodes."
  }

  assert {
    condition     = google_container_node_pool.default.management[0].auto_repair && google_container_node_pool.default.management[0].auto_upgrade
    error_message = "Nodes must auto-repair and auto-upgrade."
  }

  assert {
    condition     = google_container_node_pool.default.upgrade_settings[0].max_unavailable == 0
    error_message = "Upgrades must surge rather than take nodes away."
  }

  assert {
    condition = alltrue([
      for role in keys(google_project_iam_member.nodes) : !contains(["roles/editor", "roles/owner"], role)
    ])
    error_message = "The node service account must not have primitive roles."
  }
}

run "secrets_encryption_off_without_a_key" {
  command = plan

  variables {
    secrets_encryption_key_id = null
  }

  assert {
    condition     = google_container_cluster.this.database_encryption[0].state == "DECRYPTED"
    error_message = "Without a key, application-layer encryption must be off rather than misconfigured."
  }
}

run "binary_authorization_when_enabled" {
  command = plan

  variables {
    enable_binary_authorization = true
  }

  assert {
    condition     = google_container_cluster.this.binary_authorization[0].evaluation_mode == "PROJECT_SINGLETON_POLICY_ENFORCE"
    error_message = "Binary Authorization must be enforced when enabled."
  }
}

run "rejects_a_control_plane_open_to_the_internet" {
  command = plan

  variables {
    master_authorized_networks = [{ cidr_block = "0.0.0.0/0", display_name = "everyone" }]
  }

  expect_failures = [var.master_authorized_networks]
}

run "rejects_a_control_plane_range_that_is_not_a_28" {
  command = plan

  variables {
    master_ipv4_cidr_block = "172.16.0.0/24"
  }

  expect_failures = [var.master_ipv4_cidr_block]
}
