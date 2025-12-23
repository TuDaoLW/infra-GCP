module "gke_clusters" {
  for_each = try(local.config.gke_clusters, {})

  source = "./module/gke"

  name        = each.key
  project_id  = each.value.project_id
  location    = each.value.location
  description = each.value.description

  network    = each.value.network
  subnetwork = each.value.subnetwork

  ip_allocation_policy = each.value.ip_allocation_policy

  private_cluster_config = each.value.private_cluster_config

  service_account = each.value.service_account

  disk_size_gb       = try(each.value.disk_size_gb, 37)
  machine_type       = try(each.value.machine_type, "e2-medium")
  spot               = try(each.value.spot, false)
  initial_node_count = try(each.value.initial_node_count, 1)

  release_channel = try(each.value.release_channel, "REGULAR")
}
