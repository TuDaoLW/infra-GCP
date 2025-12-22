# module "gke_clusters" {
#   for_each = try(local.config.gke_clusters, {})

#   source = "./module/gke"

#   name                          = each.key
#   project_id                    = var.project_id
#   location                      = each.value.location
#   description                   = try(each.value.description, null)

#   network_self_link             = module.vpcs["sample-vpc"].vpc_self_link  # Adjust if multi-VPC
#   subnetwork_self_link          = module.vpcs["sample-vpc"].subnets["asia-southeast1/gke-primary"].self_link  # Use correct key

#   cluster_secondary_range_name  = each.value.ip_allocation_policy.cluster_secondary_range_name
#   services_secondary_range_name = each.value.ip_allocation_policy.services_secondary_range_name

#   release_channel               = try(each.value.release_channel, null)

#   private_cluster_config        = try(each.value.private_cluster_config, null)
#   master_authorized_networks    = try(each.value.master_authorized_networks_config.cidr_blocks, [])
#   workload_pool                 = try(each.value.workload_identity_config.workload_pool, null)
#   database_encryption           = try(each.value.database_encryption, null)

#   logging_components            = try(each.value.logging_config.enable_system_components, true) ? (try(each.value.logging_config.enable_workload_components, false) ? ["SYSTEM_COMPONENTS", "WORKLOADS"] : ["SYSTEM_COMPONENTS"]) : []

#   monitoring_components         = try(each.value.monitoring_config.enable_system_components, true) ? ["SYSTEM_COMPONENTS"] : []  # Add WORKLOADS if needed later

#   managed_prometheus_enabled    = try(each.value.monitoring_config.enable_managed_prometheus, false)
#   cost_allocation_enabled       = try(each.value.cost_management_config.enabled, false)

#   addons = {
#     http_load_balancing_disabled = try(each.value.addons_config.http_load_balancing.disabled, false)
#     network_policy_disabled      = try(each.value.addons_config.network_policy_config.disabled, false)
#   }

#   maintenance_window_start      = try(each.value.maintenance_policy.daily_maintenance_window.start_time, null)

#   enable_autopilot              = try(each.value.enable_autopilot, false)
# }