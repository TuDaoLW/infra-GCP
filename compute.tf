module "compute_instances" {
  source = "./module/vm"

  project_id = var.project_id
  labels     = try(local.config.labels, {})

  instances = {
    for name, inst in try(local.config.compute_instances, {}) :
    name => {
      zone         = inst.zone
      machine_type = inst.machine_type
      description  = try(inst.description, null)

      service_account = try(inst.service_account, null) != null ? {
        email  = "${inst.service_account}@${var.project_id}.iam.gserviceaccount.com"
        scopes = ["cloud-platform"] 
      } : null

      tags         = try(inst.tags, [])
      extra_labels = try(inst.extra_labels, {})

      disks = [
        for d in try(inst.disks, []) : {
          device_name       = d.device_name
          boot              = try(d.boot, false)
          auto_delete       = try(d.auto_delete, true)
          mode              = try(d.mode, "READ_WRITE")
          initialize_params = try(d.initialize_params, null)
        }
      ]

      network_interfaces = try(inst.network_interfaces, [])

      metadata_startup_script  = try(inst.metadata.startup-script, null)
      metadata_shutdown_script = try(inst.metadata.shutdown-script, null)
      metadata = {
        for k, v in try(inst.metadata, {}) : k => v
        if !contains(["startup-script", "shutdown-script"], k)
      }

      can_ip_forward      = try(inst.can_ip_forward, false)
      deletion_protection = try(inst.deletion_protection, false)

      confidential_instance_config = try(inst.confidential_instance_config, {})
      shielded_instance_config     = try(inst.shielded_instance_config, {})

      guest_accelerator = try(inst.guest_accelerator, [])
    }
  }

  depends_on = [module.vpcs, module.firewalls, module.iam_bindings]
}

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

  master_authorized_networks_config = try(each.value.master_authorized_networks_config, { cidr_blocks = [] })

  release_channel     = try(each.value.release_channel, "REGULAR")
  deletion_protection = try(each.value.deletion_protection, false)

  # Default node pool settings
  remove_default_node_pool              = try(each.value.remove_default_node_pool, false)
  initial_node_count                    = try(each.value.initial_node_count, 1)
  default_machine_type                  = try(each.value.machine_type, "e2-medium")
  default_disk_size_gb                  = try(each.value.disk_size_gb, 37)
  default_disk_type                     = try(each.value.disk_type, "pd-balanced")
  default_service_account               = each.value.service_account
  default_oauth_scopes                  = try(each.value.oauth_scopes, ["https://www.googleapis.com/auth/cloud-platform"])
  default_spot                          = try(each.value.spot, false)
  default_labels                        = try(each.value.labels, {})
  default_taints                        = try(each.value.taints, [])
  default_shielded_secure_boot          = try(each.value.shielded_secure_boot, true)
  default_shielded_integrity_monitoring = try(each.value.shielded_integrity_monitoring, true)

  # Default node pool autoscaling
  default_autoscaling_enabled    = try(each.value.default_autoscaling_enabled, false)
  default_autoscaling_min_cpu    = try(each.value.default_autoscaling_min_cpu, 1)
  default_autoscaling_max_cpu    = try(each.value.default_autoscaling_max_cpu, 20)
  default_autoscaling_min_memory = try(each.value.default_autoscaling_min_memory, 4)
  default_autoscaling_max_memory = try(each.value.default_autoscaling_max_memory, 100)
  # Custom node pools
  node_pools = try(each.value.node_pools, {})

  depends_on = [module.vpcs]
}
