# network

Custom-mode VPC with a GKE subnet (pod and service secondary ranges, Private Google Access, flow logs), Cloud Router + Cloud NAT for egress from private nodes, IAP-only SSH, a logged default-deny ingress rule, and optional Private Service Access.

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
| [google_compute_firewall.allow_iap_ssh](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow_internal](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.deny_all_ingress](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_global_address.private_service_access](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address) | resource |
| [google_compute_network.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [google_compute_router.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router) | resource |
| [google_compute_router_nat.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat) | resource |
| [google_compute_subnetwork.gke](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_service_networking_connection.private_service_access](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_networking_connection) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the VPC; also used as a prefix for related resources. | `string` | n/a | yes |
| pods\_cidr | Secondary range for pods. | `string` | n/a | yes |
| project\_id | Project that owns the network. | `string` | n/a | yes |
| region | Region for the subnet, router and NAT. | `string` | n/a | yes |
| services\_cidr | Secondary range for Kubernetes services. | `string` | n/a | yes |
| subnet\_cidr | Primary range for nodes. | `string` | n/a | yes |
| enable\_private\_service\_access | Reserve a range and peer it with Google services (Cloud SQL, Memorystore). | `bool` | `false` | no |
| flow\_log\_sampling | Fraction of flows recorded by VPC flow logs (0-1). | `number` | `0.5` | no |
| nat\_min\_ports\_per\_vm | Minimum NAT ports reserved per VM. | `number` | `64` | no |
| private\_service\_access\_cidr | Range reserved for Private Service Access. | `string` | `"10.100.0.0/20"` | no |

### Outputs

| Name | Description |
|------|-------------|
| network\_id | ID of the VPC. |
| network\_self\_link | Self link of the VPC. |
| pods\_range\_name | Name of the secondary range for pods. |
| services\_range\_name | Name of the secondary range for services. |
| subnet\_id | ID of the GKE subnet. |
| subnet\_self\_link | Self link of the GKE subnet. |
<!-- END_TF_DOCS -->
