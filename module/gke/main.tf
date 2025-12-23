resource "google_container_cluster" "cluster" {
  for_each = var.clusters

  project     = var.project_id
  name        = each.key
  location    = each.value.location
  description = each.value.description

  network    = each.value.network
  subnetwork = each.value.subnetwork

  dynamic "ip_allocation_policy" {
    for_each = each.value.ip_allocation_policy != null ? [each.value.ip_allocation_policy] : []
    content {
      cluster_secondary_range_name  = ip_allocation_policy.value.cluster_secondary_range_name
      services_secondary_range_name = ip_allocation_policy.value.services_secondary_range_name
    }
  }

  release_channel {
    channel = each.value.release_channel
  }

  dynamic "private_cluster_config" {
    for_each = each.value.private_cluster_config != null ? [each.value.private_cluster_config] : []
    content {
      enable_private_nodes    = private_cluster_config.value.enable_private_nodes
      enable_private_endpoint = private_cluster_config.value.enable_private_endpoint
      master_ipv4_cidr_block  = try(private_cluster_config.value.master_ipv4_cidr_block, null)  # Required only if enable_private_endpoint=true
    }
  }

  dynamic "master_authorized_networks_config" {
    for_each = try(each.value.master_authorized_networks_config.enabled, false) ? [1] : []
    content {
      dynamic "cidr_blocks" {
        for_each = try(each.value.master_authorized_networks_config.cidr_blocks, [])
        content {
          display_name = cidr_blocks.value.display_name
          cidr_block   = cidr_blocks.value.cidr_block
        }
      }
    }
  }

  dynamic "workload_identity_config" {
    for_each = try(each.value.workload_identity_config.workload_pool, null) != null ? [1] : []
    content {
      workload_pool = each.value.workload_identity_config.workload_pool
    }
  }

  dynamic "logging_config" {
    for_each = [each.value.logging_config]
    content {
      enable_components = concat(
        logging_config.value.enable_system_components ? ["SYSTEM_COMPONENTS"] : [],
        logging_config.value.enable_workload_components ? ["WORKLOADS"] : []
      )
    }
  }

  dynamic "monitoring_config" {
    for_each = [each.value.monitoring_config]
    content {
      enable_components = monitoring_config.value.enable_system_components ? ["SYSTEM_COMPONENTS"] : []

      dynamic "managed_prometheus" {
        for_each = monitoring_config.value.enable_managed_prometheus != null ? [1] : []
        content {
          enabled = monitoring_config.value.enable_managed_prometheus
        }
      }
    }
  }

  dynamic "cost_management_config" {
    for_each = each.value.cost_management_config.enabled ? [1] : []
    content {
      enabled = true
    }
  }

  dynamic "addons_config" {
    for_each = [each.value.addons_config]
    content {
      dynamic "http_load_balancing" {
        for_each = [addons_config.value.http_load_balancing]
        content {
          disabled = http_load_balancing.value.disabled
        }
      }

      dynamic "network_policy_config" {
        for_each = [addons_config.value.network_policy_config]
        content {
          disabled = network_policy_config.value.disabled
        }
      }
    }
  }

  dynamic "maintenance_policy" {
    for_each = try(each.value.maintenance_policy.daily_maintenance_window.start_time, null) != null ? [1] : []
    content {
      dynamic "daily_maintenance_window" {
        for_each = [each.value.maintenance_policy.daily_maintenance_window]
        content {
          start_time = daily_maintenance_window.value.start_time
        }
      }
    }
  }

  enable_autopilot = each.value.enable_autopilot

  remove_default_node_pool = !each.value.enable_autopilot && length(each.value.node_pools) > 0
  initial_node_count       = !each.value.enable_autopilot && length(each.value.node_pools) > 0 ? 1 : null
}

resource "google_container_node_pool" "pools" {
  for_each = {
    for pair in flatten([
      for cluster_name, cluster in var.clusters : [
        for pool_name, pool in cluster.node_pools : {
          key          = "${cluster_name}-${pool_name}"
          cluster_name = cluster_name
          pool         = pool
        }
      ]
    ]) : pair.key => pair
    if !var.clusters[pair.cluster_name].enable_autopilot
  }

  project    = var.project_id
  name       = split("-", each.key)[1]  # pool_name
  location   = var.clusters[each.value.cluster_name].location
  cluster    = google_container_cluster.cluster[each.value.cluster_name].name

  initial_node_count = each.value.pool.initial_node_count

  node_config {
    machine_type    = each.value.pool.node_config.machine_type
    disk_size_gb    = each.value.pool.node_config.disk_size_gb
    service_account = each.value.pool.node_config.service_account
    oauth_scopes    = each.value.pool.node_config.oauth_scopes

    dynamic "shielded_instance_config" {
      for_each = [each.value.pool.node_config.shielded_instance_config]
      content {
        enable_secure_boot          = shielded_instance_config.value.enable_secure_boot
        enable_integrity_monitoring = shielded_instance_config.value.enable_integrity_monitoring
      }
    }

    labels = each.value.pool.node_config.labels
    dynamic "taint" {
      for_each = each.value.pool.node_config.taints
      content {
        key    = taint.value.key
        value  = taint.value.value
        effect = taint.value.effect
      }
    }
  }

  management {
    auto_repair  = each.value.pool.management.auto_repair
    auto_upgrade = each.value.pool.management.auto_upgrade
  }

  dynamic "autoscaling" {
    for_each = each.value.pool.autoscaling != null ? [each.value.pool.autoscaling] : []
    content {
      min_node_count = autoscaling.value.min_node_count
      max_node_count = autoscaling.value.max_node_count
    }
  }
}