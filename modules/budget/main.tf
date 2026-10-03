data "google_project" "this" {
  project_id = var.project_id
}

resource "google_billing_budget" "this" {
  billing_account = var.billing_account
  display_name    = "${var.project_id} monthly budget"

  budget_filter {
    projects = ["projects/${data.google_project.this.number}"]
  }

  amount {
    specified_amount {
      currency_code = var.currency_code
      units         = tostring(var.monthly_amount)
    }
  }

  dynamic "threshold_rules" {
    for_each = var.alert_thresholds
    content {
      threshold_percent = threshold_rules.value
    }
  }

  # Forecasted spend warns before the money is actually spent.
  threshold_rules {
    threshold_percent = 1.0
    spend_basis       = "FORECASTED_SPEND"
  }
}
