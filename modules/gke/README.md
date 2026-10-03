# gke

Private GKE Standard cluster: private nodes, authorized control-plane networks, Workload Identity, Dataplane V2, Shielded Nodes, Binary Authorization, KMS-encrypted Secrets, managed Prometheus, a maintenance window, and an autoscaled node pool running as a least-privilege service account.

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
| [google_container_cluster.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster) | resource |
| [google_container_node_pool.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_node_pool) | resource |
| [google_project_iam_member.nodes](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_service_account.nodes](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| location | Region for a regional (highly available) cluster, or zone for a zonal one. | `string` | n/a | yes |
| master\_ipv4\_cidr\_block | /28 range for the control plane. | `string` | n/a | yes |
| name | Cluster name. | `string` | n/a | yes |
| network\_self\_link | VPC self link. | `string` | n/a | yes |
| pods\_range\_name | Secondary range name for pods. | `string` | n/a | yes |
| project\_id | Project for the cluster. | `string` | n/a | yes |
| services\_range\_name | Secondary range name for services. | `string` | n/a | yes |
| subnet\_self\_link | Subnet self link. | `string` | n/a | yes |
| deletion\_protection | Block terraform destroy of the cluster. | `bool` | `true` | no |
| disk\_size\_gb | Node boot disk size. | `number` | `50` | no |
| enable\_binary\_authorization | Enforce the project's Binary Authorization policy. The default project policy allows all images until you tighten it. | `bool` | `true` | no |
| enable\_private\_endpoint | Only expose the control plane on its private IP. Requires reaching it from inside the VPC (IAP, VPN or a bastion). | `bool` | `false` | no |
| labels | Labels applied to the cluster and nodes. | `map(string)` | `{}` | no |
| machine\_type | Node machine type. | `string` | `"e2-standard-2"` | no |
| maintenance\_end\_time | End of the first maintenance window (RFC 3339). | `string` | `"2025-01-04T08:00:00Z"` | no |
| maintenance\_recurrence | RRULE for the maintenance window. | `string` | `"FREQ=WEEKLY;BYDAY=SA,SU"` | no |
| maintenance\_start\_time | Start of the recurring maintenance window (RFC 3339). | `string` | `"2025-01-04T02:00:00Z"` | no |
| master\_authorized\_networks | CIDR blocks allowed to reach the control plane. | ```list(object({ cidr_block = string display_name = string }))``` | `[]` | no |
| node\_max\_count | Maximum nodes per zone. | `number` | `3` | no |
| node\_min\_count | Minimum nodes per zone. | `number` | `1` | no |
| rbac\_security\_group | gke-security-groups@<domain> group for Google Groups for RBAC. Null disables it. | `string` | `null` | no |
| release\_channel | GKE release channel. | `string` | `"REGULAR"` | no |
| secrets\_encryption\_key\_id | Cloud KMS key for application-layer secrets encryption. Null disables it. | `string` | `null` | no |
| spot | Use Spot VMs for the node pool (cheaper, can be reclaimed). | `bool` | `false` | no |

### Outputs

| Name | Description |
|------|-------------|
| cluster\_id | Cluster ID. |
| cluster\_name | Cluster name. |
| endpoint | Control plane endpoint. |
| get\_credentials\_command | Command to configure kubectl. |
| node\_service\_account | Email of the node service account. |
| workload\_identity\_pool | Workload Identity pool for Kubernetes service accounts. |
<!-- END_TF_DOCS -->
