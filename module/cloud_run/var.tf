variable "cloud_run_services" {
  description = "Map of Cloud Run service configurations"
  type = map(object({
    project_id          = string
    location            = string
    description         = optional(string)
    ingress             = optional(string, "INGRESS_TRAFFIC_ALL")  # INGRESS_TRAFFIC_ALL, INGRESS_TRAFFIC_INTERNAL_ONLY, etc.
    deletion_protection = optional(bool, false)

    image = string  # Placeholder image (e.g., ":placeholder")

    container = object({
      port        = optional(number, 8080)
      concurrency = optional(number, 80)
      cpu         = string
      memory      = string

      startup_probe = optional(object({
        http_get = optional(object({
          path = string
          port = optional(number)
        }))
        timeout_seconds   = optional(number)
        period_seconds    = optional(number)
        failure_threshold = optional(number)
      }))
    })

    scaling = object({
      min_instances = number
      max_instances = number
    })

    vpc_access = optional(object({
      connector = string  # Full self-link to VPC Access connector
      egress    = string  # ALL_TRAFFIC or PRIVATE_RANGES_ONLY
    }))

    env_vars = optional(list(object({
      name  = string
      value = string
    })), [])

    secret_env_vars = optional(list(object({
      name    = string
      secret  = string
      version = string
    })), [])

    allow_unauthenticated = optional(bool, false)

    extra_labels = optional(map(string), {})
  }))
}