# Existing variables (keep them)
variable "name" { type = string }
variable "project_id" { type = string }
variable "location" { type = string }
variable "description" { type = string }
variable "network" { type = string }
variable "subnetwork" { type = string }
variable "ip_allocation_policy" {
  type = object({
    cluster_secondary_range_name  = string
    services_secondary_range_name = string
  })
}
variable "private_cluster_config" {
  type = object({
    enable_private_nodes    = bool
    enable_private_endpoint = bool
    master_ipv4_cidr_block  = string
  })
}
variable "master_authorized_networks_config" {
  type = object({
    cidr_blocks = list(object({
      cidr_block   = string
      display_name = string
    }))
  })
  default = { cidr_blocks = [] }
}
variable "release_channel" { type = string }
variable "deletion_protection" { type = bool }

# New: Toggle for default node pool
variable "remove_default_node_pool" {
  description = "If true, remove the default node pool and use custom node pools"
  type        = bool
  default     = false
}

# For default node pool (when remove_default_node_pool = false)
variable "initial_node_count" { type = number }
variable "default_machine_type" { type = string }
variable "default_disk_size_gb" {
  type    = number
  default = 37
}
variable "default_disk_type" {
  type    = string
  default = "pd-balanced"
}
variable "default_service_account" { type = string }
variable "default_oauth_scopes" {
  type    = list(string)
  default = ["https://www.googleapis.com/auth/cloud-platform"]
}
variable "default_spot" { type = bool }
variable "default_labels" { type = map(string) }
variable "default_taints" {
  type    = list(object({ key = string, value = string, effect = string }))
  default = []
}
variable "default_shielded_secure_boot" { type = bool }
variable "default_shielded_integrity_monitoring" { type = bool }

# For custom node pools (when remove_default_node_pool = true)
variable "node_pools" {
  description = "Map of custom node pools"
  type = map(object({
    initial_node_count = optional(number, 1)
    autoscaling = optional(object({
      min_node_count  = number
      max_node_count  = number
      location_policy = optional(string, "BALANCED")
    }))
    management = optional(object({
      auto_repair  = optional(bool, true)
      auto_upgrade = optional(bool, true)
    }))
    machine_type    = string
    disk_size_gb    = optional(number, 100)
    disk_type       = optional(string, "pd-balanced")
    service_account = string
    oauth_scopes    = optional(list(string))
    spot            = optional(bool, false)
    labels          = optional(map(string), {})
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])
    shielded_secure_boot          = optional(bool, true)
    shielded_integrity_monitoring = optional(bool, true)
  }))
  default = {}
}

variable "default_autoscaling_enabled" {
  description = "Enable cluster autoscaler on default node pool"
  type        = bool
  default     = false
}

variable "default_autoscaling_min_cpu" {
  description = "Minimum CPU cores for default node pool autoscaling"
  type        = number
  default     = 1
}

variable "default_autoscaling_max_cpu" {
  description = "Maximum CPU cores for default node pool autoscaling"
  type        = number
  default     = 20
}

variable "default_autoscaling_min_memory" {
  description = "Minimum memory (GB) for default node pool autoscaling"
  type        = number
  default     = 4
}

variable "default_autoscaling_max_memory" {
  description = "Maximum memory (GB) for default node pool autoscaling"
  type        = number
  default     = 100
}
