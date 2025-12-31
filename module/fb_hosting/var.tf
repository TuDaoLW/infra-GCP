variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "site_id" {
  type        = string
  description = "Unique ID for the Firebase Hosting site (e.g., my-app-site)"
}

variable "region" {
  type        = string
  default     = "us-central1"
  description = "Default region for Cloud Run backends (overridable per rewrite)"
}

variable "hosting_config" {
  type = object({
    rewrites  = optional(list(object({
      glob  = optional(string)
      regex = optional(string)
      run = optional(object({
        service_id = string
        region     = optional(string)
      }))
      path     = optional(string)
      function = optional(string)
    })))
    redirects = optional(list(object({
      glob        = string
      regex       = optional(string)
      location    = string
      status_code = number
    })))
    headers   = optional(list(object({
      glob    = string
      regex   = optional(string)
      headers = map(string)
    })))
  })
  default     = null
  description = "Full hosting config (rewrites, redirects, headers). If null, no config applied (useful for static-only sites)"
}

variable "cloudrun_dependency" {
  type        = any
  default     = null
  description = "Dependency (e.g., module.cloudrun) to ensure backends exist"
}

variable "release_message" {
  type        = string
  default     = null
  description = "Optional release message"
}

variable "custom_domain" {
  type        = string
  default     = null
  description = "Custom domain (e.g., app.example.com). Triggers domain connection"
}
