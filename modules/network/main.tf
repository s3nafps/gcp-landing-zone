locals {
  iap_tcp_forwarding_range = "35.235.240.0/20"
}

resource "google_compute_network" "this" {
  project                         = var.project_id
  name                            = var.name
  auto_create_subnetworks         = false
  routing_mode                    = "REGIONAL"
  delete_default_routes_on_create = false
}

resource "google_compute_subnetwork" "gke" {
  project                  = var.project_id
  name                     = "${var.name}-gke-${var.region}"
  region                   = var.region
  network                  = google_compute_network.this.id
  ip_cidr_range            = var.subnet_cidr
  private_ip_google_access = true
  stack_type               = "IPV4_ONLY"

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = var.pods_cidr
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = var.services_cidr
  }

  log_config {
    aggregation_interval = "INTERVAL_5_MIN"
    flow_sampling        = var.flow_log_sampling
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# Private nodes have no public IPs; Cloud NAT gives them outbound access for image
# pulls and updates without exposing them to inbound traffic.
resource "google_compute_router" "this" {
  project = var.project_id
  name    = "${var.name}-router-${var.region}"
  region  = var.region
  network = google_compute_network.this.id
}

resource "google_compute_router_nat" "this" {
  project                            = var.project_id
  name                               = "${var.name}-nat-${var.region}"
  router                             = google_compute_router.this.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  min_ports_per_vm                   = var.nat_min_ports_per_vm
  enable_dynamic_port_allocation     = true
  max_ports_per_vm                   = 4096

  subnetwork {
    name                    = google_compute_subnetwork.gke.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_firewall" "allow_iap_ssh" {
  project       = var.project_id
  name          = "${var.name}-allow-iap-ssh"
  network       = google_compute_network.this.id
  description   = "SSH only through Identity-Aware Proxy TCP forwarding."
  direction     = "INGRESS"
  priority      = 1000
  source_ranges = [local.iap_tcp_forwarding_range]
  target_tags   = ["allow-iap-ssh"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_firewall" "allow_internal" {
  project       = var.project_id
  name          = "${var.name}-allow-internal"
  network       = google_compute_network.this.id
  description   = "Traffic between nodes, pods and services inside the VPC."
  direction     = "INGRESS"
  priority      = 1000
  source_ranges = [var.subnet_cidr, var.pods_cidr, var.services_cidr]

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "icmp"
  }

  log_config {
    metadata = "EXCLUDE_ALL_METADATA"
  }
}

resource "google_compute_firewall" "deny_all_ingress" {
  project       = var.project_id
  name          = "${var.name}-deny-all-ingress"
  network       = google_compute_network.this.id
  description   = "Explicit, logged default deny so dropped traffic is visible."
  direction     = "INGRESS"
  priority      = 65534
  source_ranges = ["0.0.0.0/0"]

  deny {
    protocol = "all"
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# Private Service Access lets managed services such as Cloud SQL and Memorystore use
# private IPs inside this VPC.
resource "google_compute_global_address" "private_service_access" {
  count = var.enable_private_service_access ? 1 : 0

  project       = var.project_id
  name          = "${var.name}-psa"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  address       = split("/", var.private_service_access_cidr)[0]
  prefix_length = tonumber(split("/", var.private_service_access_cidr)[1])
  network       = google_compute_network.this.id
}

resource "google_service_networking_connection" "private_service_access" {
  count = var.enable_private_service_access ? 1 : 0

  network                 = google_compute_network.this.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_service_access[0].name]
}
