locals {
  name = "${var.prefix}-${var.environment}"
  labels = merge(var.labels, {
    environment = var.environment
    managed-by  = "terraform"
  })
  services = [
    "artifactregistry.googleapis.com",
    "cloudkms.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "containersecurity.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "servicenetworking.googleapis.com",
    "sts.googleapis.com",
  ]
}

module "services" {
  source = "../project-services"

  project_id = var.project_id
  services   = concat(local.services, var.billing_account == null ? [] : ["billingbudgets.googleapis.com"])
}

module "network" {
  source = "../network"

  project_id                    = var.project_id
  name                          = local.name
  region                        = var.region
  subnet_cidr                   = var.subnet_cidr
  pods_cidr                     = var.pods_cidr
  services_cidr                 = var.services_cidr
  enable_private_service_access = var.enable_private_service_access

  depends_on = [module.services]
}

module "kms" {
  source = "../kms"

  project_id    = var.project_id
  location      = var.region
  key_ring_name = "${local.name}-keyring"

  depends_on = [module.services]
}

module "gke" {
  source = "../gke"

  project_id                  = var.project_id
  name                        = local.name
  location                    = var.regional_cluster ? var.region : "${var.region}-${var.zone_suffix}"
  network_self_link           = module.network.network_self_link
  subnet_self_link            = module.network.subnet_self_link
  pods_range_name             = module.network.pods_range_name
  services_range_name         = module.network.services_range_name
  master_ipv4_cidr_block      = var.master_ipv4_cidr_block
  enable_private_endpoint     = var.enable_private_endpoint
  master_authorized_networks  = var.master_authorized_networks
  release_channel             = var.release_channel
  enable_binary_authorization = var.enable_binary_authorization
  rbac_security_group         = var.rbac_security_group
  secrets_encryption_key_id   = module.kms.gke_secrets_key_id
  deletion_protection         = var.deletion_protection
  machine_type                = var.machine_type
  spot                        = var.spot_nodes
  node_min_count              = var.node_min_count
  node_max_count              = var.node_max_count
  labels                      = local.labels

  depends_on = [module.kms]
}

module "iam" {
  source = "../iam"

  project_id        = var.project_id
  project_roles     = var.project_roles
  github_repository = var.github_repository

  depends_on = [module.services]
}

module "registry" {
  source = "../artifact-registry"

  project_id   = var.project_id
  location     = var.region
  kms_key_name = module.kms.artifact_registry_key_id
  labels       = local.labels

  depends_on = [module.kms]
}

module "budget" {
  source = "../budget"
  count  = var.billing_account == null ? 0 : 1

  project_id      = var.project_id
  billing_account = var.billing_account
  monthly_amount  = var.monthly_budget

  depends_on = [module.services]
}
