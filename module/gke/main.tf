resource "google_container_cluster" "cluster" {
  name        = var.name
  location    = var.location # Use zone for testing (e.g., asia-southeast1-a)
  project     = var.project_id
  description = var.description

  # Keep and configure default node pool
  initial_node_count = var.initial_node_count

  node_config {
    machine_type    = var.machine_type
    disk_size_gb    = var.disk_size_gb
    disk_type       = var.disk_type # Optional: "pd-balanced" (default), "pd-ssd", etc.
    service_account = var.service_account
    oauth_scopes    = var.oauth_scopes

    spot = var.spot # For spot VMs

    shielded_instance_config {
      enable_secure_boot          = try(var.shielded_secure_boot, true)
      enable_integrity_monitoring = try(var.shielded_integrity_monitoring, true)
    }

    labels = var.labels
    dynamic "taint" {
      for_each = var.taints
      content {
        key    = taint.value.key
        value  = taint.value.value
        effect = taint.value.effect
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

  # Add other configs you need (logging, monitoring, etc.) – keep minimal for now
  release_channel {
    channel = var.release_channel
  }

  deletion_protection = var.deletion_protection
}
