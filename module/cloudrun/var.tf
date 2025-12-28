variable "service_name" {
  type        = string
  description = "Name of the Cloud Run service"
}

variable "project_id" {
  type        = string
}

variable "region" {
  type        = string
  default     = "asia-southeast1"
}

variable "description" {
  type        = string
  default     = ""
}

variable "container_image" {
  type        = string
  description = "Container image URL (e.g., gcr.io/project/nginx:latest)"
}

variable "container_port" {
  type        = number
  default     = 80
}

variable "cpu_limit" {
  type        = string
  default     = "1"
}

variable "memory_limit" {
  type        = string
  default     = "512Mi"
}

variable "min_instances" {
  type        = number
  default     = 0
}

variable "max_instances" {
  type        = number
  default     = 100
}

variable "service_account_email" {
  type        = string
  description = "Service account for Cloud Run (with DB access)"
}

variable "env_vars" {
  type        = map(string)
  default     = {}
}

variable "secrets" {
  type = map(object({
    secret_name = string
    version     = string
  }))
  default = {}
}

# Direct VPC Egress
variable "direct_vpc_enabled" {
  type        = bool
  default     = false
  description = "Enable Direct VPC egress (no connector needed)"
}

variable "network_self_link" {
  type        = string
  default     = null
  description = "VPC network self link (required if direct_vpc_enabled)"
}

variable "subnetwork_self_link" {
  type        = string
  default     = null
  description = "Optional: specific subnetwork for egress"
}

variable "network_tags" {
  type        = list(string)
  default     = []
}

variable "vpc_egress_setting" {
  type        = string
  default     = "ALL_TRAFFIC"
  description = "ALL_TRAFFIC or PRIVATE_RANGES_ONLY"
}

# Public access
variable "allow_unauthenticated" {
  type        = bool
  default     = true
}

# Custom domain
variable "custom_domain" {
  type        = string
  default     = null
}