# artifact-registry

Docker repository encrypted with a customer-managed key, with immutable tags and cleanup policies that keep recent versions and delete old untagged images.

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
| [google_artifact_registry_repository.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| kms\_key\_name | Cloud KMS key that encrypts the repository (customer-managed encryption). | `string` | n/a | yes |
| location | Region of the repository. | `string` | n/a | yes |
| project\_id | Project for the repository. | `string` | n/a | yes |
| immutable\_tags | Prevent a tag from being moved to a different image. | `bool` | `true` | no |
| keep\_recent\_versions | Image versions always kept regardless of age. | `number` | `10` | no |
| labels | Labels for the repository. | `map(string)` | `{}` | no |
| repository\_id | Repository name. | `string` | `"containers"` | no |
| untagged\_retention\_days | Delete untagged images older than this many days. | `number` | `7` | no |

### Outputs

| Name | Description |
|------|-------------|
| repository\_url | Docker repository URL for docker push/pull. |
<!-- END_TF_DOCS -->
