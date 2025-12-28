resource "google_sql_database_instance" "instance" {
  name                = var.instance_name
  project             = var.project_id
  region              = var.region
  database_version    = var.database_version
  root_password       = var.root_password
  deletion_protection = var.deletion_protection

  settings {
    tier                  = var.machine_type
    availability_type     = var.high_availability ? "REGIONAL" : "ZONAL"
    disk_type             = var.disk_type
    disk_size             = var.disk_size_gb
    disk_autoresize       = var.disk_autoresize
    disk_autoresize_limit = var.disk_autoresize_limit

    backup_configuration {
      enabled    = var.backup_enabled
      start_time = var.backup_start_time

      # PITR for PostgreSQL and SQL Server
      point_in_time_recovery_enabled = (
        var.backup_enabled &&
        contains(["POSTGRES", "SQLSERVER"], split("_", var.database_version)[0])
      )

      # Binary log for MySQL PITR
      binary_log_enabled = (
        var.backup_enabled &&
        split("_", var.database_version)[0] == "MYSQL"
      )

      transaction_log_retention_days = var.transaction_log_retention_days

      dynamic "backup_retention_settings" {
        for_each = var.backup_enabled && var.retained_backups != null ? [1] : []
        content {
          retained_backups = var.retained_backups
          retention_unit   = "COUNT"
        }
      }
    }

    dynamic "maintenance_window" {
      for_each = var.maintenance_window != null ? [var.maintenance_window] : []
      content {
        day  = maintenance_window.value.day
        hour = maintenance_window.value.hour
      }
    }

    ip_configuration {
      ipv4_enabled    = var.public_ip
      private_network = var.private_network_self_link

      # Use ssl_mode only (no require_ssl)
      ssl_mode = var.ssl_mode # New variable

      dynamic "authorized_networks" {
        for_each = var.authorized_networks
        content {
          name  = authorized_networks.value.name
          value = authorized_networks.value.value
        }
      }
    }

    dynamic "database_flags" {
      for_each = var.database_flags
      content {
        name  = database_flags.key
        value = database_flags.value
      }
    }

    dynamic "insights_config" {
      for_each = var.query_insights_enabled ? [1] : []
      content {
        query_insights_enabled  = true
        record_application_tags = var.record_application_tags
        record_client_address   = var.record_client_address
        query_plans_per_minute  = try(var.query_plans_per_minute, 5)
      }
    }
  }

  timeouts {
    create = "60m"
    update = "60m"
    delete = "60m"
  }
}

# Databases and users remain the same
resource "google_sql_database" "databases" {
  for_each = var.databases

  name      = each.key
  instance  = google_sql_database_instance.instance.name
  charset   = try(each.value.charset, null)
  collation = try(each.value.collation, null)
}

resource "google_sql_user" "users" {
  for_each = var.users

  name     = each.key
  instance = google_sql_database_instance.instance.name
  password = each.value.password
  host     = try(each.value.host, "%")
}
