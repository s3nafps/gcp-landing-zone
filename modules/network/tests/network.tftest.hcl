mock_provider "google" {}

variables {
  project_id    = "lz-test-project"
  name          = "lz-dev"
  region        = "europe-west1"
  subnet_cidr   = "10.10.0.0/20"
  pods_cidr     = "10.20.0.0/14"
  services_cidr = "10.24.0.0/20"
}

run "subnet_is_private_and_logged" {
  command = plan

  assert {
    condition     = google_compute_network.this.auto_create_subnetworks == false
    error_message = "The VPC must be custom mode."
  }

  assert {
    condition     = google_compute_subnetwork.gke.private_ip_google_access
    error_message = "Private Google Access must be on so private nodes reach Google APIs."
  }

  assert {
    condition     = google_compute_subnetwork.gke.log_config[0].flow_sampling == 0.5
    error_message = "VPC flow logs must be enabled."
  }

  assert {
    condition     = length(google_compute_subnetwork.gke.secondary_ip_range) == 2
    error_message = "The subnet needs pod and service secondary ranges."
  }
}

run "egress_through_nat_with_error_logging" {
  command = plan

  assert {
    condition     = google_compute_router_nat.this.log_config[0].enable && google_compute_router_nat.this.log_config[0].filter == "ERRORS_ONLY"
    error_message = "Cloud NAT must log errors."
  }

  assert {
    condition     = google_compute_router_nat.this.source_subnetwork_ip_ranges_to_nat == "LIST_OF_SUBNETWORKS"
    error_message = "NAT must only cover the listed subnet."
  }
}

run "firewall_allows_ssh_only_through_iap" {
  command = plan

  assert {
    condition     = google_compute_firewall.allow_iap_ssh.source_ranges == toset(["35.235.240.0/20"])
    error_message = "SSH must only be allowed from the IAP range."
  }

  assert {
    condition     = google_compute_firewall.deny_all_ingress.priority == 65534 && contains(google_compute_firewall.deny_all_ingress.source_ranges, "0.0.0.0/0")
    error_message = "A logged deny-all ingress rule must exist below every allow rule."
  }

  assert {
    condition     = length(google_compute_global_address.private_service_access) == 0
    error_message = "Private Service Access must be opt-in."
  }
}

run "private_service_access_when_enabled" {
  command = plan

  variables {
    enable_private_service_access = true
  }

  assert {
    condition     = google_compute_global_address.private_service_access[0].prefix_length == 20
    error_message = "The reserved range must use the configured prefix."
  }
}

run "rejects_an_invalid_cidr" {
  command = plan

  variables {
    subnet_cidr = "10.10.0.0/40"
  }

  expect_failures = [var.subnet_cidr]
}
