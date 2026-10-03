variable "project_id" {
  description = "Project that owns the key ring."
  type        = string
}

variable "location" {
  description = "Key ring location; must match the GKE cluster's region."
  type        = string
}

variable "key_ring_name" {
  description = "Name of the key ring. Key rings cannot be deleted, so pick a stable name."
  type        = string
}

variable "rotation_period" {
  description = "Automatic rotation period, in seconds with an s suffix."
  type        = string
  default     = "7776000s" # 90 days

  validation {
    condition     = can(regex("^[0-9]+s$", var.rotation_period)) && tonumber(trimsuffix(var.rotation_period, "s")) <= 7776000
    error_message = "rotation_period must be in seconds (for example 7776000s) and at most 90 days."
  }
}

variable "protection_level" {
  description = "SOFTWARE or HSM."
  type        = string
  default     = "SOFTWARE"

  validation {
    condition     = contains(["SOFTWARE", "HSM"], var.protection_level)
    error_message = "protection_level must be SOFTWARE or HSM."
  }
}
