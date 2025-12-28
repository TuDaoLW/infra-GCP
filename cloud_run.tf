# module "cloud_run" {
#   for_each = try(local.config.cloud_run_services, {})
#   source   = "./module/cloud_run"

#   cloud_run_services = { (each.key) = each.value }
# }