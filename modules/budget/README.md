# budget

Monthly billing budget with actual-spend thresholds and a forecasted-spend alert.

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
| [google_billing_budget.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/billing_budget) | resource |
| [google_project.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| billing\_account | Billing account ID (XXXXXX-XXXXXX-XXXXXX). | `string` | n/a | yes |
| monthly\_amount | Monthly budget in whole currency units. | `number` | n/a | yes |
| project\_id | Project the budget covers. | `string` | n/a | yes |
| alert\_thresholds | Fractions of actual spend that trigger e-mails to billing admins. | `list(number)` | ```[ 0.5, 0.9, 1 ]``` | no |
| currency\_code | Currency of the billing account. | `string` | `"USD"` | no |

### Outputs

| Name | Description |
|------|-------------|
| budget\_id | ID of the budget. |
<!-- END_TF_DOCS -->
