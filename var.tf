variable "env" {
  description = "The environment to deploy (e.g., home, prod)"
  type        = string
  default     = "home"
}

variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "test-482612"
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "asia-southeast1"
}

# variable "backend_bucket" {
#   description = "GCS Bucket for Terraform state"
#   type        = string
# }
