terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.45"
    }
  }

  # backend "gcs" {
  #   bucket  = var.backend_bucket
  #   prefix  = "terraform/state/${var.env}"
  # }
}
