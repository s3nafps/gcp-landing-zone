# kms

Key ring with two customer-managed keys rotated every 90 days or less: one for GKE application-layer secrets encryption and one for Artifact Registry. Each key is usable only by its service agent.

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
| [google_kms_crypto_key.artifact_registry](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key) | resource |
| [google_kms_crypto_key.gke_secrets](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key) | resource |
| [google_kms_crypto_key_iam_member.artifact_registry_service_agent](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key_iam_member) | resource |
| [google_kms_crypto_key_iam_member.gke_service_agent](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key_iam_member) | resource |
| [google_kms_key_ring.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_key_ring) | resource |
| [google_project.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| key\_ring\_name | Name of the key ring. Key rings cannot be deleted, so pick a stable name. | `string` | n/a | yes |
| location | Key ring location; must match the GKE cluster's region. | `string` | n/a | yes |
| project\_id | Project that owns the key ring. | `string` | n/a | yes |
| protection\_level | SOFTWARE or HSM. | `string` | `"SOFTWARE"` | no |
| rotation\_period | Automatic rotation period, in seconds with an s suffix. | `string` | `"7776000s"` | no |

### Outputs

| Name | Description |
|------|-------------|
| artifact\_registry\_key\_iam\_ready | Resolves after the Artifact Registry service agent can use the key; use in depends\_on. |
| artifact\_registry\_key\_id | ID of the key that encrypts the Artifact Registry repository. |
| gke\_key\_iam\_ready | Resolves after the GKE service agent can use the key; use in depends\_on. |
| gke\_secrets\_key\_id | ID of the key used for GKE application-layer secrets encryption. |
<!-- END_TF_DOCS -->
