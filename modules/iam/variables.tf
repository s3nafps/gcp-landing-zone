variable "project_id" {
  description = "Project for the IAM bindings."
  type        = string
}

variable "project_roles" {
  description = "Additive project role bindings: map of role to members (group:, user:, serviceAccount:)."
  type        = map(list(string))
  default     = {}

  validation {
    condition = alltrue(flatten([
      for role, members in var.project_roles : [
        for m in members : can(regex("^(user|group|serviceAccount|domain|principal|principalSet):", m))
      ]
    ]))
    error_message = "Each member must start with user:, group:, serviceAccount:, domain:, principal: or principalSet:."
  }

  validation {
    condition     = !contains(keys(var.project_roles), "roles/owner") && !contains(keys(var.project_roles), "roles/editor")
    error_message = "Do not grant roles/owner or roles/editor through this module; use narrower predefined roles."
  }
}

variable "github_repository" {
  description = "owner/repo allowed to impersonate the CI service account. Null skips Workload Identity Federation."
  type        = string
  default     = null

  validation {
    condition     = var.github_repository == null || can(regex("^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$", var.github_repository))
    error_message = "github_repository must look like owner/repo."
  }
}

variable "workload_identity_pool_id" {
  description = "ID of the Workload Identity pool."
  type        = string
  default     = "github"
}

variable "github_deploy_refs" {
  description = "Git refs whose workflows may use the deploy account."
  type        = list(string)
  default     = ["refs/heads/main"]

  validation {
    condition     = alltrue([for r in var.github_deploy_refs : startswith(r, "refs/") && !strcontains(r, "*")])
    error_message = "Each deploy ref must be a full ref such as refs/heads/main, without wildcards."
  }
}

variable "allow_pull_request_plans" {
  description = "Create a read-only account that pull request workflows can use for terraform plan."
  type        = bool
  default     = true
}

variable "ci_service_account_prefix" {
  description = "Prefix for the CI service account IDs (<prefix>-deploy, <prefix>-plan)."
  type        = string
  default     = "github"
}

variable "ci_deploy_roles" {
  description = "Project roles granted to the deploy account."
  type        = list(string)
  default = [
    "roles/container.admin",
    "roles/compute.networkAdmin",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.serviceAccountUser",
    "roles/cloudkms.admin",
    "roles/artifactregistry.admin",
    "roles/resourcemanager.projectIamAdmin",
    "roles/serviceusage.serviceUsageAdmin",
  ]

  validation {
    condition     = !contains(var.ci_deploy_roles, "roles/owner") && !contains(var.ci_deploy_roles, "roles/editor")
    error_message = "The deploy account must not be Owner or Editor."
  }
}

variable "ci_plan_roles" {
  description = "Read-only project roles granted to the plan account."
  type        = list(string)
  default = [
    "roles/browser",
    "roles/iam.securityReviewer",
    "roles/container.clusterViewer",
    "roles/compute.networkViewer",
    "roles/cloudkms.viewer",
    "roles/artifactregistry.reader",
    "roles/serviceusage.serviceUsageViewer",
  ]

  validation {
    condition     = alltrue([for r in var.ci_plan_roles : !can(regex("(admin|Admin|editor|owner|writer|Writer|User)$", r))])
    error_message = "The plan account must only hold read-only roles."
  }
}
