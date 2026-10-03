variable "project_id" {
  description = "Project the budget covers."
  type        = string
}

variable "billing_account" {
  description = "Billing account ID (XXXXXX-XXXXXX-XXXXXX)."
  type        = string

  validation {
    condition     = can(regex("^[A-F0-9]{6}-[A-F0-9]{6}-[A-F0-9]{6}$", var.billing_account))
    error_message = "billing_account must look like 0X0X0X-0X0X0X-0X0X0X."
  }
}

variable "monthly_amount" {
  description = "Monthly budget in whole currency units."
  type        = number
}

variable "currency_code" {
  description = "Currency of the billing account."
  type        = string
  default     = "USD"
}

variable "alert_thresholds" {
  description = "Fractions of actual spend that trigger e-mails to billing admins."
  type        = list(number)
  default     = [0.5, 0.9, 1.0]
}
