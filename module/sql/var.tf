variable "instance_name" {
  type        = string
  description = "Name of the Cloud SQL instance"
}

variable "project_id" {
  type        = string
}

variable "region" {
  type        = string
  default     = "asia-southeast1"
}

variable "database_version" {
  type        = string
  description = "MYSQL_8_0 or POSTGRES_15, etc."
}

variable "machine_type" {
  type        = string
  default     = "db-f1-micro"
}

variable "disk_type" {
  type    = string
  default = "PD_SSD"
  validation {
    condition     = contains(["PD_SSD", "PD_BALANCED", "PD_HDD"], var.disk_type)
    error_message = "disk_type must be PD_SSD, PD_BALANCED, or PD_HDD."
  }
}
variable "disk_size_gb" {
  type        = number
  default     = 10
}

variable "disk_autoresize" {
  type        = bool
  default     = true
}

variable "disk_autoresize_limit" {
  type        = number
  default     = 0  # 0 = no limit
}

variable "high_availability" {
  type        = bool
  default     = false
}

variable "public_ip" {
  type        = bool
  default     = false
  description = "Set to true for public IP (not recommended for prod)"
}

variable "private_network_self_link" {
  type        = string
  description = "Self link of VPC network for private IP"
}

variable "backup_enabled" {
  type    = bool
  default = true
}

variable "backup_start_time" {
  type    = string
  default = "03:00"
}

variable "point_in_time_recovery_enabled" {
  type    = bool
  default = true
}

variable "transaction_log_retention_days" {
  type    = number
  default = null
}

variable "maintenance_window" {
  type = object({
    day  = number  # 1-7, Monday = 1
    hour = number  # 0-23
  })
  default = null
}

variable "database_flags" {
  type    = map(string)
  default = {}
}

variable "query_insights_enabled" {
  type    = bool
  default = false
}

variable "record_application_tags" {
  type    = bool
  default = false
}

variable "record_client_address" {
  type    = bool
  default = false
}

variable "deletion_protection" {
  type    = bool
  default = true
}

variable "databases" {
  type = map(object({
    charset   = optional(string)
    collation = optional(string)
  }))
  default = {}
}

variable "users" {
  type = map(object({
    password = string
    host     = optional(string)
  }))
  description = "Map of username => { password, host }"
  default     = {}
}
# ----
variable "allocated_ip_range" {
  type        = string
  default     = null
  description = "PSC IP range name (optional)"
}

variable "require_ssl" {
  type        = bool
  default     = true
  description = "Enforce SSL (uses ssl_mode)"
}

variable "retained_backups" {
  type        = number
  default     = 7
  description = "Number of automated backups to retain (7–365)"
}

variable "query_plans_per_minute" {
  type        = number
  default     = 5
}

variable "authorized_networks" {
  type = list(object({
    name  = string
    value = string
  }))
  default = []
  description = "List of authorized CIDRs for access (e.g., management VM subnet)"
}

variable "ssl_mode" {
  type        = string
  description = "SSL enforcement mode"
  default     = "ENCRYPTED_ONLY"  # Safe default
  validation {
    condition     = contains(["ALLOW_UNENCRYPTED_AND_ENCRYPTED", "ENCRYPTED_ONLY", "TRUSTED_CLIENT_CERTIFICATE_REQUIRED"], var.ssl_mode)
    error_message = "Invalid ssl_mode. Use ALLOW_UNENCRYPTED_AND_ENCRYPTED, ENCRYPTED_ONLY, or TRUSTED_CLIENT_CERTIFICATE_REQUIRED."
  }
}

variable "root_password" {
  type        = string
  description = "Root password for SQL Server instances (required for SQLSERVER)"
  default     = null
  sensitive   = true
}