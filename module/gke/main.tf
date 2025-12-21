resource "google_container_cluster" "cluster" {
  name        = var.name
  project     = var.project_id
  location    = var.location
  description = var.description

  network    = var.network_self_link
  subnetwork = var.subnetwork_self_link

  ip_allocation_policy {
    cluster_secondary_range_name  = var.cluster_secondary_range_name
    services_secondary_range_name = var.services_secondary_range_name
  }

  dynamic "release_channel" {
    for_each = var.release_channel != null ? [var.release_channel] : []
    content {
      channel = upper(var.release_channel)
    }
  }

  dynamic "private_cluster_config" {
    for_each = var.private_cluster_config != null ? [var.private_cluster_config] : []
    content {
      enable_private_nodes    = private_cluster_config.value.enable_private_nodes
      enable_private_endpoint = private_cluster_config.value.enable_private_endpoint
      master_ipv4_cidr_block  = private_cluster_config.value.master_ipv4_cidr_block
    }
  }

  dynamic "master_authorized_networks_config" {
    for_each = length(var.master_authorized_networks) > 0 ? [1] : []
    content {
      dynamic "cidr_blocks" {
        for_each = var.master_authorized_networks
        content {
          display_name = cidr_blocks.value.display_name
          cidr_block   = cidr_blocks.value.cidr_block
        }
      }
    }
  }

  dynamic "workload_identity_config" {
    for_each = var.workload_pool != null ? [var.workload_pool] : []
    content {
      workload_pool = workload_identity_config.value
    }
  }

  dynamic "database_encryption" {
    for_each = var.database_encryption != null ? [var.database_encryption] : []
    content {
      state    = database_encryption.value.state
      key_name = database_encryption.value.key_name
    }
  }

  logging_config {
    enable_components = var.logging_components
  }

  monitoring_config {
    enable_components = var.monitoring_components

    dynamic "managed_prometheus" {
      for_each = var.managed_prometheus_enabled ? [1] : []
      content {
        enabled = true
      }
    }
  }

  dynamic "cost_management_config" {
    for_each = var.cost_allocation_enabled ? [1] : []
    content {
      enabled = true
    }
  }
  addons_config {
    http_load_balancing {
      disabled = lookup(var.addons, "http_load_balancing_disabled", false)
    }

    dynamic "network_policy_config" {
      for_each = var.enable_autopilot ? [] : [1] # Skip entirely for Autopilot
      content {
        disabled = lookup(var.addons, "network_policy_disabled", false)
      }
    }
  }
  dynamic "maintenance_policy" {
    for_each = var.maintenance_window_start != null ? [1] : []
    content {
      daily_maintenance_window {
        start_time = var.maintenance_window_start
      }
    }
  }

  enable_autopilot = var.enable_autopilot

  # For Autopilot, no node pools needed
  # If not Autopilot, you can extend later with separate node_pool module
}
