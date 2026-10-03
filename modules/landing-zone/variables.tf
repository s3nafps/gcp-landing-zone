variable "project_id" {
  description = "Existing GCP project to build the landing zone in."
  type        = string

  validation {
    condition     = can(regex("^[a-z][-a-z0-9]{4,28}[a-z0-9]$", var.project_id))
    error_message = "project_id must be a valid GCP project ID."
  }
}

variable "prefix" {
  description = "Short prefix for resource names."
  type        = string
  default     = "lz"

  validation {
    condition     = can(regex("^[a-z][a-z0-9]{1,9}$", var.prefix))
    error_message = "prefix must be 2-10 lowercase letters or digits, starting with a letter."
  }
}

variable "environment" {
  description = "Environment name, used in resource names and labels."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging or prod."
  }
}

variable "region" {
  description = "Region for all regional resources."
  type        = string
  default     = "europe-west1"
}

variable "zone_suffix" {
  description = "Zone letter used when regional_cluster is false."
  type        = string
  default     = "b"
}

variable "regional_cluster" {
  description = "Run the control plane and nodes across three zones."
  type        = bool
  default     = false
}

variable "subnet_cidr" {
  description = "Node range."
  type        = string
  default     = "10.10.0.0/20"
}

variable "pods_cidr" {
  description = "Pod range."
  type        = string
  default     = "10.20.0.0/14"
}

variable "services_cidr" {
  description = "Service range."
  type        = string
  default     = "10.24.0.0/20"
}

variable "master_ipv4_cidr_block" {
  description = "/28 range for the GKE control plane."
  type        = string
  default     = "172.16.0.0/28"
}

variable "enable_private_endpoint" {
  description = "Expose the control plane only on its private IP."
  type        = bool
  default     = false
}

variable "master_authorized_networks" {
  description = "CIDR blocks allowed to reach the control plane."
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = []
}

variable "release_channel" {
  description = "GKE release channel."
  type        = string
  default     = "REGULAR"
}

variable "enable_binary_authorization" {
  description = "Enforce Binary Authorization."
  type        = bool
  default     = true
}

variable "rbac_security_group" {
  description = "gke-security-groups@<domain> for Google Groups for RBAC. Null disables it."
  type        = string
  default     = null
}

variable "enable_private_service_access" {
  description = "Peer a range with Google managed services (Cloud SQL, Memorystore)."
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Block terraform destroy of the cluster."
  type        = bool
  default     = true
}

variable "machine_type" {
  description = "Node machine type."
  type        = string
  default     = "e2-standard-2"
}

variable "spot_nodes" {
  description = "Use Spot VMs for nodes."
  type        = bool
  default     = false
}

variable "node_min_count" {
  description = "Minimum nodes per zone."
  type        = number
  default     = 1
}

variable "node_max_count" {
  description = "Maximum nodes per zone."
  type        = number
  default     = 3
}

variable "project_roles" {
  description = "Additive project role bindings for people and groups."
  type        = map(list(string))
  default     = {}
}

variable "github_repository" {
  description = "owner/repo allowed to deploy through Workload Identity Federation. Null disables it."
  type        = string
  default     = null
}

variable "billing_account" {
  description = "Billing account for the budget alert. Null skips the budget."
  type        = string
  default     = null
}

variable "monthly_budget" {
  description = "Monthly budget in the billing account's currency."
  type        = number
  default     = 100
}

variable "labels" {
  description = "Extra labels for all resources that support them."
  type        = map(string)
  default     = {}
}
