variable "name" {
  description = "Name of the GKE cluster"
  type        = string
}

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "location" {
  description = "Location (regional or zonal) for the cluster"
  type        = string
}

variable "description" {
  description = "Description of the cluster"
  type        = string
  default     = null
}

variable "network_self_link" {
  description = "Self-link of the VPC network"
  type        = string
}

variable "subnetwork_self_link" {
  description = "Self-link of the subnetwork for nodes"
  type        = string
}

variable "cluster_secondary_range_name" {
  description = "Secondary range name for Pods"
  type        = string
}

variable "services_secondary_range_name" {
  description = "Secondary range name for Services"
  type        = string
}

variable "release_channel" {
  description = "Release channel (e.g., REGULAR, STABLE)"
  type        = string
  default     = null
}

variable "private_cluster_config" {
  description = "Private cluster configuration"
  type = object({
    enable_private_nodes    = bool
    enable_private_endpoint = bool
    master_ipv4_cidr_block  = string
  })
  default = null
}

variable "master_authorized_networks" {
  description = "List of master authorized CIDR blocks"
  type = list(object({
    display_name = optional(string)
    cidr_block   = string
  }))
  default = []
}

variable "workload_pool" {
  description = "Workload Identity pool (project_id.svc.id.goog)"
  type        = string
  default     = null
}

variable "database_encryption" {
  description = "Database encryption config"
  type = object({
    state    = string  # ENCRYPTED or DECRYPTED
    key_name = string
  })
  default = null
}

variable "logging_components" {
  description = "List of logging components to enable (SYSTEM_COMPONENTS, WORKLOADS)"
  type        = list(string)
  default     = ["SYSTEM_COMPONENTS"]
}

variable "monitoring_components" {
  description = "List of monitoring components to enable (SYSTEM_COMPONENTS, WORKLOADS, etc.)"
  type        = list(string)
  default     = ["SYSTEM_COMPONENTS"]
}

variable "managed_prometheus_enabled" {
  description = "Enable Managed Prometheus"
  type        = bool
  default     = false
}

variable "cost_allocation_enabled" {
  description = "Enable GKE cost allocation (enable_cost_management)"
  type        = bool
  default     = false
}

variable "addons" {
  description = "Addons configuration"
  type = object({
    http_load_balancing_disabled = optional(bool, false)
    network_policy_disabled      = optional(bool, false)
  })
  default = {}
}

variable "maintenance_window_start" {
  description = "Daily maintenance window start time (e.g., 03:00)"
  type        = string
  default     = null
}

variable "enable_autopilot" {
  description = "Enable GKE Autopilot mode"
  type        = bool
  default     = false
}