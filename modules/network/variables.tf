variable "project_id" {
  description = "Project that owns the network."
  type        = string
}

variable "name" {
  description = "Name of the VPC; also used as a prefix for related resources."
  type        = string

  validation {
    condition     = can(regex("^[a-z]([-a-z0-9]{0,40}[a-z0-9])?$", var.name))
    error_message = "name must be lowercase letters, digits and hyphens, start with a letter, and be at most 42 characters."
  }
}

variable "region" {
  description = "Region for the subnet, router and NAT."
  type        = string
}

variable "subnet_cidr" {
  description = "Primary range for nodes."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.subnet_cidr))
    error_message = "subnet_cidr must be a valid IPv4 CIDR block."
  }
}

variable "pods_cidr" {
  description = "Secondary range for pods."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.pods_cidr))
    error_message = "pods_cidr must be a valid IPv4 CIDR block."
  }
}

variable "services_cidr" {
  description = "Secondary range for Kubernetes services."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.services_cidr))
    error_message = "services_cidr must be a valid IPv4 CIDR block."
  }
}

variable "flow_log_sampling" {
  description = "Fraction of flows recorded by VPC flow logs (0-1)."
  type        = number
  default     = 0.5

  validation {
    condition     = var.flow_log_sampling > 0 && var.flow_log_sampling <= 1
    error_message = "flow_log_sampling must be greater than 0 and at most 1."
  }
}

variable "nat_min_ports_per_vm" {
  description = "Minimum NAT ports reserved per VM."
  type        = number
  default     = 64
}

variable "enable_private_service_access" {
  description = "Reserve a range and peer it with Google services (Cloud SQL, Memorystore)."
  type        = bool
  default     = false
}

variable "private_service_access_cidr" {
  description = "Range reserved for Private Service Access."
  type        = string
  default     = "10.100.0.0/20"

  validation {
    condition     = can(cidrnetmask(var.private_service_access_cidr))
    error_message = "private_service_access_cidr must be a valid IPv4 CIDR block."
  }
}
