variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "zone_name" {
  type        = string
  description = "Internal name of the zone (e.g., example-com-public)"
}

variable "dns_name" {
  type        = string
  description = "Domain name with trailing dot (e.g., example.com.)"
}

variable "description" {
  type        = string
  default     = "Managed by Terraform"
}

variable "visibility" {
  type        = string
  description = "public or private"
  validation {
    condition     = contains(["public", "private"], var.visibility)
    error_message = "Visibility must be 'public' or 'private'."
  }
}

variable "dnssec_enabled" {
  type        = bool
  default     = false
  description = "Enable DNSSEC (free, only for public zones)"
}

variable "private_visibility_networks" {
  type        = list(string)
  default     = []
  description = "List of VPC network self-links for private zone visibility"
}

variable "labels" {
  type        = map(string)
  default     = {}
  description = "Labels for cost allocation and organization"
}

variable "recordsets" {
  type = map(object({
    name    = string           # subdomain, empty for apex
    type    = string           # A, CNAME, TXT, etc.
    ttl     = number
    rrdatas = list(string)
  }))
  default     = {}
  description = "Optional initial DNS records"
}