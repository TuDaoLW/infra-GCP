variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "network_self_link" {
  description = "Self-link of the VPC network"
  type        = string
}

# variable "global_labels" {
#   description = "Global labels to apply to all firewall rules"
#   type        = map(string)
#   default     = {}
# }

variable "rules" {
  description = "Map of firewall rule configurations (key = rule name)"
  type = map(object({
    direction                = string  # INGRESS or EGRESS
    priority                 = number
    action                   = string  # ALLOW or DENY
    description              = optional(string)
    extra_labels             = optional(map(string), {})
    source_ranges            = optional(list(string), [])
    destination_ranges       = optional(list(string), [])
    target_tags              = optional(list(string), [])
    target_service_accounts  = optional(list(string), [])  # Add later if needed
    source_service_accounts  = optional(list(string), [])  # For identity-aware rules
    protocols = list(object({
      protocol = string  # tcp, udp, icmp, or others like esp, ah, sctp
      ports    = optional(list(string), [])
    }))
    # For DENY all, can use protocol: "all" as a single entry
  }))
  default = {}
}