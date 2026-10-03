# landing-zone

Composes every module into one environment. The env roots in envs/ call this module with environment-specific settings.

<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.9 |
| google | >= 8.0, < 9.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| budget | ../budget | n/a |
| gke | ../gke | n/a |
| iam | ../iam | n/a |
| kms | ../kms | n/a |
| network | ../network | n/a |
| registry | ../artifact-registry | n/a |
| services | ../project-services | n/a |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | Environment name, used in resource names and labels. | `string` | n/a | yes |
| project\_id | Existing GCP project to build the landing zone in. | `string` | n/a | yes |
| billing\_account | Billing account for the budget alert. Null skips the budget. | `string` | `null` | no |
| deletion\_protection | Block terraform destroy of the cluster. | `bool` | `true` | no |
| enable\_binary\_authorization | Enforce Binary Authorization. | `bool` | `true` | no |
| enable\_private\_endpoint | Expose the control plane only on its private IP. | `bool` | `false` | no |
| enable\_private\_service\_access | Peer a range with Google managed services (Cloud SQL, Memorystore). | `bool` | `false` | no |
| github\_repository | owner/repo allowed to deploy through Workload Identity Federation. Null disables it. | `string` | `null` | no |
| labels | Extra labels for all resources that support them. | `map(string)` | `{}` | no |
| machine\_type | Node machine type. | `string` | `"e2-standard-2"` | no |
| master\_authorized\_networks | CIDR blocks allowed to reach the control plane. | ```list(object({ cidr_block = string display_name = string }))``` | `[]` | no |
| master\_ipv4\_cidr\_block | /28 range for the GKE control plane. | `string` | `"172.16.0.0/28"` | no |
| monthly\_budget | Monthly budget in the billing account's currency. | `number` | `100` | no |
| node\_max\_count | Maximum nodes per zone. | `number` | `3` | no |
| node\_min\_count | Minimum nodes per zone. | `number` | `1` | no |
| pods\_cidr | Pod range. | `string` | `"10.20.0.0/14"` | no |
| prefix | Short prefix for resource names. | `string` | `"lz"` | no |
| project\_roles | Additive project role bindings for people and groups. | `map(list(string))` | `{}` | no |
| rbac\_security\_group | gke-security-groups@<domain> for Google Groups for RBAC. Null disables it. | `string` | `null` | no |
| region | Region for all regional resources. | `string` | `"europe-west1"` | no |
| regional\_cluster | Run the control plane and nodes across three zones. | `bool` | `false` | no |
| release\_channel | GKE release channel. | `string` | `"REGULAR"` | no |
| services\_cidr | Service range. | `string` | `"10.24.0.0/20"` | no |
| spot\_nodes | Use Spot VMs for nodes. | `bool` | `false` | no |
| subnet\_cidr | Node range. | `string` | `"10.10.0.0/20"` | no |
| zone\_suffix | Zone letter used when regional\_cluster is false. | `string` | `"b"` | no |

### Outputs

| Name | Description |
|------|-------------|
| cluster\_name | GKE cluster name. |
| get\_credentials\_command | Configure kubectl for the cluster. |
| github\_deploy\_service\_account | service\_account for workflows on the deploy branches. |
| github\_plan\_service\_account | service\_account for pull request plan workflows (read-only). |
| github\_workload\_identity\_provider | workload\_identity\_provider for google-github-actions/auth. |
| network\_id | VPC ID. |
| registry\_url | Artifact Registry Docker repository. |
| workload\_identity\_pool | Workload Identity pool for Kubernetes service accounts. |
<!-- END_TF_DOCS -->
