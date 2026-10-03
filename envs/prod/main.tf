# Production: regional cluster across three zones, on-demand nodes, STABLE channel,
# Binary Authorization enforced and deletion protection on.
module "landing_zone" {
  source = "../../modules/landing-zone"

  project_id  = var.project_id
  environment = "prod"
  region      = var.region

  regional_cluster              = true
  spot_nodes                    = false
  machine_type                  = "e2-standard-4"
  node_min_count                = 1
  node_max_count                = 5
  release_channel               = "STABLE"
  enable_binary_authorization   = true
  enable_private_service_access = true
  deletion_protection           = true
  master_authorized_networks    = var.master_authorized_networks

  subnet_cidr            = "10.30.0.0/20"
  pods_cidr              = "10.40.0.0/14"
  services_cidr          = "10.44.0.0/20"
  master_ipv4_cidr_block = "172.16.0.16/28"

  github_repository = var.github_repository
  project_roles     = var.project_roles
  billing_account   = var.billing_account
  monthly_budget    = 500
}
