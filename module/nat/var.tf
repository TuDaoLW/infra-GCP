variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "Region for the Cloud Router and NAT"
  type        = string
}

variable "network_self_link" {
  description = "Self-link of the VPC network"
  type        = string
}

variable "routers" {
  description = "Map of Cloud Router configurations (key = router name)"
  type = map(object({
    description = optional(string)
  }))
  default = {}
}

variable "nat_gateways" {
  description = "Map of Cloud NAT configurations (key = NAT name)"
  type = map(object({
    router_name                        = string
    nat_ip_allocation_mode             = optional(string, "AUTO_ONLY")           # AUTO_ONLY or MANUAL_ONLY
    nat_ips                            = optional(list(string), [])              # If MANUAL_ONLY
    source_subnetwork_ip_ranges_to_nat = optional(string, "LIST_OF_SUBNETWORKS") # Or ALL_SUBNETWORKS_ALL_IP_RANGES
    subnetworks = optional(list(object({
      name                    = string
      source_ip_ranges_to_nat = optional(list(string), ["ALL_IP_RANGES"])
    })), [])
    log_config = optional(object({
      enable = bool
      filter = optional(string, "ALL") # ALL, ERRORS_ONLY, TRANSLATIONS_ONLY
    }), null)
    min_ports_per_vm                 = optional(number, null)
    icmp_idle_timeout_sec            = optional(number, null)
    tcp_established_idle_timeout_sec = optional(number, null)
    tcp_transitory_idle_timeout_sec  = optional(number, null)
    udp_idle_timeout_sec             = optional(number, null)
  }))
  default = {}
}
