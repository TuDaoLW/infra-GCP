variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "location" {
  type        = string
  description = "Regional location (e.g., asia-southeast1) — choose closest to deployments for zero egress"
}

variable "repository_id" {
  type        = string
  description = "Unique repository name"
}

variable "description" {
  type    = string
  default = "Docker container registry"
}

variable "immutable_tags" {
  type        = bool
  default     = true
  description = "Prevent tag overwrites for security"
}

variable "cleanup_policies" {
  type = map(object({
    action = string # "DELETE" or "KEEP"
    condition = optional(object({
      tag_state             = optional(string)
      tag_prefixes          = optional(list(string))
      version_name_prefixes = optional(list(string))
      older_than            = optional(string) # Duration like "30d" or "2592000s"
    }))
    most_recent_versions = optional(object({
      keep_count = number
    }))
  }))
  default     = {}
  description = "Cleanup policies to auto-delete old images (major cost saver)"
}

variable "labels" {
  type    = map(string)
  default = {}
}
