resource "google_container_cluster" "cluster" {
  name        = var.name
  location    = var.location
  project     = var.project_id
  description = var.description

  # Control default node pool creation
  remove_default_node_pool = var.remove_default_node_pool
  initial_node_count       = var.initial_node_count

  # Optional: Configure the default node pool if not removed
  dynamic "node_config" {
    for_each = var.remove_default_node_pool ? [] : [1]
    content {
      machine_type    = var.default_machine_type
      disk_size_gb    = var.default_disk_size_gb
      disk_type       = var.default_disk_type
      service_account = var.default_service_account
      oauth_scopes    = var.default_oauth_scopes
      spot            = var.default_spot

      shielded_instance_config {
        enable_secure_boot          = try(var.default_shielded_secure_boot, true)
        enable_integrity_monitoring = try(var.default_shielded_integrity_monitoring, true)
      }

      labels = var.default_labels

      dynamic "taint" {
        for_each = var.default_taints
        content {
          key    = taint.value.key
          value  = taint.value.value
          effect = taint.value.effect
        }
      }
    }
  }

  network    = var.network
  subnetwork = var.subnetwork

  networking_mode = "VPC_NATIVE"

  ip_allocation_policy {
    cluster_secondary_range_name  = var.ip_allocation_policy.cluster_secondary_range_name
    services_secondary_range_name = var.ip_allocation_policy.services_secondary_range_name
  }

  private_cluster_config {
    enable_private_nodes    = var.private_cluster_config.enable_private_nodes
    enable_private_endpoint = var.private_cluster_config.enable_private_endpoint
    master_ipv4_cidr_block  = var.private_cluster_config.master_ipv4_cidr_block
  }

  dynamic "master_authorized_networks_config" {
    for_each = var.private_cluster_config.enable_private_endpoint ? [1] : []
    content {
      dynamic "cidr_blocks" {
        for_each = var.master_authorized_networks_config.cidr_blocks
        content {
          cidr_block   = cidr_blocks.value.cidr_block
          display_name = cidr_blocks.value.display_name
        }
      }
      gcp_public_cidrs_access_enabled = false
    }
  }

  release_channel {
    channel = var.release_channel
  }

  deletion_protection = var.deletion_protection
}

# Separate custom node pools (used when remove_default_node_pool = true)
resource "google_container_node_pool" "pools" {
  for_each = var.remove_default_node_pool ? var.node_pools : {}

  name       = each.key
  location   = var.location
  cluster    = google_container_cluster.cluster.name
  project    = var.project_id

  initial_node_count = try(each.value.initial_node_count, 1)

  dynamic "autoscaling" {
    for_each = try(each.value.autoscaling, null) != null ? [each.value.autoscaling] : []
    content {
      min_node_count  = autoscaling.value.min_node_count
      max_node_count  = autoscaling.value.max_node_count
      location_policy = try(autoscaling.value.location_policy, "BALANCED")
    }
  }

  dynamic "management" {
    for_each = try(each.value.management, null) != null ? [each.value.management] : []
    content {
      auto_repair  = try(management.value.auto_repair, true)
      auto_upgrade = try(management.value.auto_upgrade, true)
    }
  }

  node_config {
    machine_type    = each.value.machine_type
    disk_size_gb    = try(each.value.disk_size_gb, 100)
    disk_type       = try(each.value.disk_type, "pd-balanced")
    service_account = each.value.service_account
    oauth_scopes    = try(each.value.oauth_scopes, ["https://www.googleapis.com/auth/cloud-platform"])
    spot            = try(each.value.spot, false)

    labels = try(each.value.labels, {})

    dynamic "taint" {
      for_each = try(each.value.taints, [])
      content {
        key    = taint.value.key
        value  = taint.value.value
        effect = taint.value.effect
      }
    }

    shielded_instance_config {
      enable_secure_boot          = try(each.value.shielded_secure_boot, true)
      enable_integrity_monitoring = try(each.value.shielded_integrity_monitoring, true)
    }
  }

  depends_on = [google_container_cluster.cluster]
}