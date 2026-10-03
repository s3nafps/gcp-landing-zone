variable "project_id" {
  description = "Project for the cluster."
  type        = string
}

variable "name" {
  description = "Cluster name."
  type        = string

  validation {
    condition     = can(regex("^[a-z]([-a-z0-9]{0,22}[a-z0-9])$", var.name))
    error_message = "name must be 2-24 lowercase letters, digits or hyphens, starting with a letter (it is reused in the node service account id)."
  }
}

variable "location" {
  description = "Region for a regional (highly available) cluster, or zone for a zonal one."
  type        = string
}

variable "network_self_link" {
  description = "VPC self link."
  type        = string
}

variable "subnet_self_link" {
  description = "Subnet self link."
  type        = string
}

variable "pods_range_name" {
  description = "Secondary range name for pods."
  type        = string
}

variable "services_range_name" {
  description = "Secondary range name for services."
  type        = string
}

variable "master_ipv4_cidr_block" {
  description = "/28 range for the control plane."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.master_ipv4_cidr_block)) && endswith(var.master_ipv4_cidr_block, "/28")
    error_message = "master_ipv4_cidr_block must be a /28 CIDR block."
  }
}

variable "enable_private_endpoint" {
  description = "Only expose the control plane on its private IP. Requires reaching it from inside the VPC (IAP, VPN or a bastion)."
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

  validation {
    condition     = alltrue([for n in var.master_authorized_networks : can(cidrnetmask(n.cidr_block)) && n.cidr_block != "0.0.0.0/0"])
    error_message = "Every authorized network must be a valid CIDR block, and 0.0.0.0/0 is not allowed."
  }
}

variable "release_channel" {
  description = "GKE release channel."
  type        = string
  default     = "REGULAR"

  validation {
    condition     = contains(["RAPID", "REGULAR", "STABLE"], var.release_channel)
    error_message = "release_channel must be RAPID, REGULAR or STABLE."
  }
}

variable "enable_binary_authorization" {
  description = "Enforce the project's Binary Authorization policy. The default project policy allows all images until you tighten it."
  type        = bool
  default     = true
}

variable "rbac_security_group" {
  description = "gke-security-groups@<domain> group for Google Groups for RBAC. Null disables it."
  type        = string
  default     = null

  validation {
    condition     = var.rbac_security_group == null || can(regex("^gke-security-groups@", var.rbac_security_group))
    error_message = "rbac_security_group must be named gke-security-groups@<your-domain>."
  }
}

variable "secrets_encryption_key_id" {
  description = "Cloud KMS key for application-layer secrets encryption. Null disables it."
  type        = string
  default     = null
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

variable "disk_size_gb" {
  description = "Node boot disk size."
  type        = number
  default     = 50
}

variable "spot" {
  description = "Use Spot VMs for the node pool (cheaper, can be reclaimed)."
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

  validation {
    condition     = var.node_max_count >= 1
    error_message = "node_max_count must be at least 1."
  }
}

variable "maintenance_start_time" {
  description = "Start of the recurring maintenance window (RFC 3339)."
  type        = string
  default     = "2025-01-04T02:00:00Z"
}

variable "maintenance_end_time" {
  description = "End of the first maintenance window (RFC 3339)."
  type        = string
  default     = "2025-01-04T08:00:00Z"
}

variable "maintenance_recurrence" {
  description = "RRULE for the maintenance window."
  type        = string
  default     = "FREQ=WEEKLY;BYDAY=SA,SU"
}

variable "labels" {
  description = "Labels applied to the cluster and nodes."
  type        = map(string)
  default     = {}
}
