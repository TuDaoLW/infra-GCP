variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "service_accounts" {
  description = "Map of service accounts to create"
  type = map(object({
    account_id   = string
    display_name = string
    description  = optional(string)
    extra_labels = optional(map(string), {})
  }))
  default = {}
}

variable "custom_roles" {
  description = "Map of custom project-level roles to create"
  type = map(object({
    role_id      = string
    title        = string
    description  = optional(string)
    stage        = optional(string, "GA")
    permissions  = list(string)
    extra_labels = optional(map(string), {})
  }))
  default = {}
}

variable "role_bindings" {
  description = "Map of IAM bindings (project, bucket, or serviceAccount level)"
  type = map(object({
    role          = string
    members       = list(string)
    resource_type = string # "project", "bucket", "serviceAccount"
    resource_id   = string # project_id, bucket name, or SA email
    description   = optional(string)
    condition = optional(object({
      title       = string
      description = optional(string)
      expression  = string
    }))
  }))
  default = {}
}
