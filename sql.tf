module "cloudsql" {
  for_each = try(local.config.cloudsql_instances, {})

  source = "./module/sql"

  instance_name    = each.key
  project_id       = var.project_id
  region           = each.value.region
  database_version = each.value.database_version

  machine_type          = each.value.machine_type
  disk_type             = try(each.value.disk_type, "PD_SSD")
  disk_size_gb          = each.value.disk_size_gb
  disk_autoresize       = try(each.value.disk_autoresize, true)
  disk_autoresize_limit = try(each.value.disk_autoresize_limit, 0)

  high_availability = try(each.value.high_availability, false)

  public_ip                 = try(each.value.public_ip, false)
  private_network_self_link = module.vpcs["sample-vpc"].vpc_self_link
  require_ssl               = try(each.value.require_ssl, true)
  authorized_networks       = try(each.value.authorized_networks, [])

  backup_enabled                 = try(each.value.backup_enabled, true)
  backup_start_time              = try(each.value.backup_start_time, "03:00")
  point_in_time_recovery_enabled = try(each.value.point_in_time_recovery_enabled, true)
  retained_backups               = try(each.value.retained_backups, 7)
  ssl_mode                       = try(each.value.ssl_mode, "ENCRYPTED_ONLY")
  maintenance_window             = try(each.value.maintenance_window, null)
  root_password                  = try(each.value.root_password, null)
  database_flags                 = try(each.value.database_flags, {})

  deletion_protection = try(each.value.deletion_protection, true)

  databases = try(each.value.databases, {})
  users     = try(each.value.users, {})
  depends_on = [ module.psa ]
}
