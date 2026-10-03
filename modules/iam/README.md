# iam

Additive project IAM bindings plus keyless GitHub Actions access through Workload Identity Federation: a deploy account usable only from the deploy branches, and a read-only plan account for pull requests.

<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.9 |
| google | >= 8.0, < 9.0 |

### Providers

| Name | Version |
|------|---------|
| google | 8.5.0 |

### Resources

| Name | Type |
|------|------|
| [google_iam_workload_identity_pool.github](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool) | resource |
| [google_iam_workload_identity_pool_provider.github](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool_provider) | resource |
| [google_project_iam_member.deploy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.plan](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_service_account.deploy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account.plan](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_iam_member.deploy_workload_identity](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) | resource |
| [google_service_account_iam_member.plan_workload_identity](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project\_id | Project for the IAM bindings. | `string` | n/a | yes |
| allow\_pull\_request\_plans | Create a read-only account that pull request workflows can use for terraform plan. | `bool` | `true` | no |
| ci\_deploy\_roles | Project roles granted to the deploy account. | `list(string)` | ```[ "roles/container.admin", "roles/compute.networkAdmin", "roles/iam.serviceAccountAdmin", "roles/iam.serviceAccountUser", "roles/cloudkms.admin", "roles/artifactregistry.admin", "roles/resourcemanager.projectIamAdmin", "roles/serviceusage.serviceUsageAdmin" ]``` | no |
| ci\_plan\_roles | Read-only project roles granted to the plan account. | `list(string)` | ```[ "roles/browser", "roles/iam.securityReviewer", "roles/container.clusterViewer", "roles/compute.networkViewer", "roles/cloudkms.viewer", "roles/artifactregistry.reader", "roles/serviceusage.serviceUsageViewer" ]``` | no |
| ci\_service\_account\_prefix | Prefix for the CI service account IDs (<prefix>-deploy, <prefix>-plan). | `string` | `"github"` | no |
| github\_deploy\_refs | Git refs whose workflows may use the deploy account. | `list(string)` | ```[ "refs/heads/main" ]``` | no |
| github\_repository | owner/repo allowed to impersonate the CI service account. Null skips Workload Identity Federation. | `string` | `null` | no |
| project\_roles | Additive project role bindings: map of role to members (group:, user:, serviceAccount:). | `map(list(string))` | `{}` | no |
| workload\_identity\_pool\_id | ID of the Workload Identity pool. | `string` | `"github"` | no |

### Outputs

| Name | Description |
|------|-------------|
| deploy\_service\_account\_email | service\_account for workflows on the deploy branches. |
| plan\_service\_account\_email | service\_account for pull request plan workflows. |
| workload\_identity\_provider | Value for the workload\_identity\_provider input of google-github-actions/auth. |
<!-- END_TF_DOCS -->
