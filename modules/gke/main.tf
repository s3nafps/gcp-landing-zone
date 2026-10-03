locals {
  node_sa_roles = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/stackdriver.resourceMetadata.writer",
    "roles/autoscaling.metricsWriter",
    "roles/artifactregistry.reader",
  ]
}

# Nodes run as a dedicated service account with only the roles they need, instead
# of the Compute Engine default account that has project-wide Editor.
resource "google_service_account" "nodes" {
  project      = var.project_id
  account_id   = "${var.name}-nodes"
  display_name = "GKE nodes for ${var.name}"
}

resource "google_project_iam_member" "nodes" {
  for_each = toset(local.node_sa_roles)

  project = var.project_id
  role    = each.value
  member  = google_service_account.nodes.member
}

resource "google_container_cluster" "this" {
  #checkov:skip=CKV_GCP_12:Dataplane V2 (ADVANCED_DATAPATH) enforces NetworkPolicy natively and cannot be combined with the legacy network_policy block.
  #checkov:skip=CKV_GCP_65:Google Groups for RBAC needs a Google Workspace domain; set rbac_security_group to enable it.
  project  = var.project_id
  name     = var.name
  location = var.location

  network    = var.network_self_link
  subnetwork = var.subnet_self_link

  deletion_protection      = var.deletion_protection
  remove_default_node_pool = true
  initial_node_count       = 1

  networking_mode = "VPC_NATIVE"
  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_range_name
    services_secondary_range_name = var.services_range_name
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = var.enable_private_endpoint
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block

    master_global_access_config {
      enabled = true
    }
  }

  master_authorized_networks_config {
    gcp_public_cidrs_access_enabled = false

    dynamic "cidr_blocks" {
      for_each = var.master_authorized_networks
      content {
        cidr_block   = cidr_blocks.value.cidr_block
        display_name = cidr_blocks.value.display_name
      }
    }
  }

  release_channel {
    channel = var.release_channel
  }

  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  dynamic "authenticator_groups_config" {
    for_each = var.rbac_security_group == null ? [] : [var.rbac_security_group]
    content {
      security_group = authenticator_groups_config.value
    }
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Dataplane V2 (eBPF) enforces Kubernetes NetworkPolicy without Calico.
  datapath_provider           = "ADVANCED_DATAPATH"
  enable_shielded_nodes       = true
  enable_intranode_visibility = true
  enable_legacy_abac          = false

  binary_authorization {
    evaluation_mode = var.enable_binary_authorization ? "PROJECT_SINGLETON_POLICY_ENFORCE" : "DISABLED"
  }

  database_encryption {
    state    = var.secrets_encryption_key_id == null ? "DECRYPTED" : "ENCRYPTED"
    key_name = var.secrets_encryption_key_id
  }

  security_posture_config {
    mode               = "BASIC"
    vulnerability_mode = "VULNERABILITY_BASIC"
  }

  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }

  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]

    managed_prometheus {
      enabled = true
    }
  }

  addons_config {
    http_load_balancing {
      disabled = false
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
    gce_persistent_disk_csi_driver_config {
      enabled = true
    }
  }

  maintenance_policy {
    recurring_window {
      start_time = var.maintenance_start_time
      end_time   = var.maintenance_end_time
      recurrence = var.maintenance_recurrence
    }
  }

  cost_management_config {
    enabled = true
  }

  resource_labels = var.labels

  # Settings for the temporary default pool, which is deleted right after creation.
  node_config {
    service_account = google_service_account.nodes.email
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }

  lifecycle {
    ignore_changes = [node_config, initial_node_count]
  }
}

resource "google_container_node_pool" "default" {
  project  = var.project_id
  name     = "${var.name}-default"
  cluster  = google_container_cluster.this.id
  location = var.location

  initial_node_count = var.node_min_count

  autoscaling {
    min_node_count  = var.node_min_count
    max_node_count  = var.node_max_count
    location_policy = "BALANCED"
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  upgrade_settings {
    strategy        = "SURGE"
    max_surge       = 1
    max_unavailable = 0
  }

  node_config {
    machine_type    = var.machine_type
    disk_size_gb    = var.disk_size_gb
    disk_type       = "pd-balanced"
    image_type      = "COS_CONTAINERD"
    spot            = var.spot
    service_account = google_service_account.nodes.email
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
    labels          = var.labels
    tags            = ["gke-node", var.name]

    metadata = {
      disable-legacy-endpoints = "true"
    }

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }

  lifecycle {
    ignore_changes = [initial_node_count]
  }

  depends_on = [google_project_iam_member.nodes]
}
