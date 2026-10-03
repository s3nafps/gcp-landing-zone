variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "region" {
  description = "Region for all regional resources."
  type        = string
  default     = "europe-west1"
}

variable "master_authorized_networks" {
  description = "CIDR blocks allowed to reach the GKE control plane, for example your office or VPN egress IP."
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = []
}

variable "github_repository" {
  description = "owner/repo allowed to deploy through Workload Identity Federation."
  type        = string
  default     = null
}

variable "project_roles" {
  description = "Additive project role bindings for people and groups."
  type        = map(list(string))
  default     = {}
}

variable "billing_account" {
  description = "Billing account for the budget alert. Null skips the budget."
  type        = string
  default     = null
}
