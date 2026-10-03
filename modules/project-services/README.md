# project-services

Enables the Google Cloud APIs the landing zone needs. APIs stay enabled on destroy so other workloads are not broken.

<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.9 |
| google | >= 8.0, < 9.0 |

### Providers

| Name | Version |
|------|---------|
| google | >= 8.0, < 9.0 |

### Resources

| Name | Type |
|------|------|
| [google_project_service.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project\_id | Project to enable the APIs in. | `string` | n/a | yes |
| services | APIs to enable, for example container.googleapis.com. | `list(string)` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| services | Enabled APIs, for use in depends\_on. |
<!-- END_TF_DOCS -->
