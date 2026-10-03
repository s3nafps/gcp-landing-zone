variable "project_id" {
  description = "Project for the repository."
  type        = string
}

variable "location" {
  description = "Region of the repository."
  type        = string
}

variable "repository_id" {
  description = "Repository name."
  type        = string
  default     = "containers"
}

variable "kms_key_name" {
  description = "Cloud KMS key that encrypts the repository (customer-managed encryption)."
  type        = string
}

variable "immutable_tags" {
  description = "Prevent a tag from being moved to a different image."
  type        = bool
  default     = true
}

variable "keep_recent_versions" {
  description = "Image versions always kept regardless of age."
  type        = number
  default     = 10
}

variable "untagged_retention_days" {
  description = "Delete untagged images older than this many days."
  type        = number
  default     = 7
}

variable "labels" {
  description = "Labels for the repository."
  type        = map(string)
  default     = {}
}
