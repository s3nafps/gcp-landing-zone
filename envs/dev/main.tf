# Development: zonal cluster on Spot VMs to keep cost low. Deletion protection is
# off so the environment can be torn down and rebuilt freely.
module "landing_zone" {
  source = "../../modules/landing-zone"

  project_id  = var.project_id
  environment = "dev"
  region      = var.region

  regional_cluster           = false
  spot_nodes                 = true
  machine_type               = "e2-standard-2"
  node_min_count             = 1
  node_max_count             = 3
  release_channel            = "REGULAR"
  deletion_protection        = false
  master_authorized_networks = var.master_authorized_networks

  github_repository = var.github_repository
  project_roles     = var.project_roles
  billing_account   = var.billing_account
  monthly_budget    = 50
}
