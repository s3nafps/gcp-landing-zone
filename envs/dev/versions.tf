terraform {
  required_version = ">= 1.9"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 8.5"
    }
  }

  # Partial configuration: pass the bucket with
  #   terraform init -backend-config="bucket=<state bucket from bootstrap>"
  backend "gcs" {
    prefix = "landing-zone/dev"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region

  default_labels = {
    managed-by = "terraform"
  }
}
