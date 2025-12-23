variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "clusters" {
  description = "Map of GKE clusters to create (key = cluster name)"
  type = map(object({
    location    = string
    description = optional(string)

    network    = string
    subnetwork = string

    ip_allocation_policy = optional(object({
      cluster_secondary_range_name  = string
      services_secondary_range_name = string
    }), null)

    release_channel = optional(string, "REGULAR")

    private_cluster_config = optional(object({
      enable_private_nodes    = optional(bool, true)
      enable_private_endpoint = optional(bool, true)
      master_ipv4_cidr_block  = optional(string) # Made optional; required only when private endpoint enabled
    }), null)

    master_authorized_networks_config = optional(object({
      enabled = optional(bool, false)
      cidr_blocks = optional(list(object({
        display_name = string
        cidr_block   = string
      })), [])
    }), null)

    workload_identity_config = optional(object({
      workload_pool = optional(string) # Made optional; default provided in root module
    }), null)

    logging_config = optional(object({
      enable_system_components   = optional(bool, true)
      enable_workload_components = optional(bool, false)
      }), {
      enable_system_components   = true
      enable_workload_components = false
    })

    monitoring_config = optional(object({
      enable_system_components  = optional(bool, true)
      enable_managed_prometheus = optional(bool, false)
      }), {
      enable_system_components  = true
      enable_managed_prometheus = false
    })

    cost_management_config = optional(object({
      enabled = optional(bool, false)
    }), { enabled = false })

    addons_config = optional(object({
      http_load_balancing   = optional(object({ disabled = optional(bool, false) }), {})
      network_policy_config = optional(object({ disabled = optional(bool, false) }), {})
    }), {})

    maintenance_policy = optional(object({
      daily_maintenance_window = optional(object({
        start_time = optional(string, "03:00") # Made optional with sensible default
      }), null)
    }), null)

    enable_autopilot = optional(bool, false)

    node_pools = optional(map(object({
      initial_node_count = optional(number)
      node_config = object({
        machine_type    = string
        disk_size_gb    = optional(number, 100)
        service_account = string
        oauth_scopes    = optional(list(string), ["https://www.googleapis.com/auth/cloud-platform"])
        shielded_instance_config = optional(object({
          enable_secure_boot          = optional(bool, true)
          enable_integrity_monitoring = optional(bool, true)
        }), {})
        labels = optional(map(string), {})
        taints = optional(list(object({
          key    = string
          value  = string
          effect = string
        })), [])
      })
      management = optional(object({
        auto_repair  = optional(bool, true)
        auto_upgrade = optional(bool, true)
      }), {})
      autoscaling = optional(object({
        min_node_count = number
        max_node_count = number
      }), null)
    })), {})
  }))
  default = {}
}

variable "labels" {
  description = "Optional global labels"
  type        = map(string)
  default     = {}
}
