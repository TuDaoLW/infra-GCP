variable "name" {
  description = "Name of the VPC network (e.g., sample-vpc)"
  type        = string
}

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "auto_create_subnetworks" {
  description = "Whether to auto-create subnetworks (should be false for custom mode)"
  type        = bool
  default     = false
}

variable "routing_mode" {
  description = "Routing mode: REGIONAL or GLOBAL"
  type        = string
  default     = "REGIONAL"
}

variable "mtu" {
  description = "Maximum Transmission Unit"
  type        = number
  default     = null
}

variable "description" {
  description = "Description of the VPC"
  type        = string
  default     = null
}

variable "tags" {
  description = "Network tags for the VPC (rarely used, but available for future firewall targeting if needed)"
  type        = list(string)
  default     = []
}

variable "subnets" {
  description = "List of subnet configurations"
  type = list(object({
    name                     = string
    region                   = string
    ip_cidr_range            = string
    private_ip_google_access = optional(bool, true)
    description              = optional(string)
    purpose                  = optional(string)  # e.g., REGIONAL_MANAGED_PROXY
    role                     = optional(string)  # e.g., ACTIVE
    tags                     = optional(list(string), [])  # Network tags for firewall targeting
    secondary_ip_ranges = optional(list(object({
      range_name    = string
      ip_cidr_range = string
    })), [])
  }))
  default = []
}