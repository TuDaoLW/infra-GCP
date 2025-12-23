variable "name" { type = string }
variable "project_id" { type = string }
variable "location" { type = string } # Zone for testing
variable "description" {
  type    = string
  default = null
}

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

variable "initial_node_count" {
  type    = number
  default = 1
}

variable "machine_type" {
  type    = string
  default = "e2-medium"
}
variable "disk_size_gb" {
  type    = number
  default = 37
}
variable "disk_type" {
  type    = string
  default = null
}
variable "service_account" { type = string }
variable "oauth_scopes" {
  type    = list(string)
  default = ["https://www.googleapis.com/auth/cloud-platform"]
}
variable "spot" {
  type    = bool
  default = false
}

variable "labels" {
  type    = map(string)
  default = {}
}
variable "taints" {
  type    = list(object({ key = string, value = string, effect = string }))
  default = []
}

variable "shielded_secure_boot" {
  type    = bool
  default = true
}
variable "shielded_integrity_monitoring" {
  type    = bool
  default = true
}

variable "release_channel" {
  type    = string
  default = "REGULAR"
}
variable "deletion_protection" {
  type    = bool
  default = false
}

variable "master_authorized_networks_config" {
  description = "Configuration for master authorized networks"
  type = object({
    cidr_blocks = list(object({
      cidr_block   = string
      display_name = string
    }))
  })
  default = {
    cidr_blocks = []
  }
}
