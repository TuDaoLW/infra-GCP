variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "instances" {
  description = "Map of VM instances to create (key = instance name)"
  type = map(object({
    zone         = string
    machine_type = string
    description  = optional(string)

    service_account = optional(object({
      email  = string
      scopes = optional(list(string), ["cloud-platform"])
    }))

    tags         = optional(list(string), [])
    extra_labels = optional(map(string), {})

    disks = list(object({
      device_name = string
      boot        = optional(bool, false)
      auto_delete = optional(bool, true)
      mode        = optional(string, "READ_WRITE")

      initialize_params = optional(object({
        image   = optional(string) # image family or full self_link
        size_gb = optional(number)
        type    = optional(string, "pd-balanced")
        labels  = optional(map(string), {})
      }))
    }))

    network_interfaces = list(object({
      subnetwork = string
      network_ip = optional(string)
      access_configs = optional(list(object({
        nat_ip       = optional(string)
        network_tier = optional(string, "PREMIUM")
      })), [])
      alias_ip_ranges = optional(list(object({
        ip_cidr_range         = string
        subnetwork_range_name = optional(string)
      })), [])
    }))

    metadata                 = optional(map(string), {})
    metadata_startup_script  = optional(string)
    metadata_shutdown_script = optional(string)

    can_ip_forward      = optional(bool, false)
    deletion_protection = optional(bool, false)

    confidential_instance_config = optional(object({
      enable_confidential_compute = optional(bool, false)
    }), {})

    shielded_instance_config = optional(object({
      enable_secure_boot          = optional(bool, true)
      enable_vtpm                 = optional(bool, true)
      enable_integrity_monitoring = optional(bool, true)
      }), {
      enable_secure_boot          = true
      enable_vtpm                 = true
      enable_integrity_monitoring = true
    })

    guest_accelerator = optional(list(object({
      type  = string
      count = number
    })), [])
  }))
  default = {}
}

variable "labels" {
  description = "Optional global labels to merge with per-instance extra_labels"
  type        = map(string)
  default     = {}
}
