variable "project_id" {
  description = "Project to enable the APIs in."
  type        = string
}

variable "services" {
  description = "APIs to enable, for example container.googleapis.com."
  type        = list(string)
}
