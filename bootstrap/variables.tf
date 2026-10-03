variable "project_id" {
  description = "Project that hosts the state bucket (often a dedicated seed or management project)."
  type        = string
}

variable "bucket_name" {
  description = "Globally unique bucket name."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][-a-z0-9_.]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "bucket_name must be a valid Cloud Storage bucket name."
  }
}

variable "location" {
  description = "Bucket location. A multi-region (EU, US) survives a regional outage."
  type        = string
  default     = "EU"
}

variable "state_versions_to_keep" {
  description = "Older state versions kept for rollback."
  type        = number
  default     = 20
}

variable "access_log_bucket" {
  description = "Bucket that receives access logs for the state bucket."
  type        = string
}

variable "state_admins" {
  description = "Members allowed to read and write state, for example the CI service account."
  type        = list(string)
  default     = []
}
