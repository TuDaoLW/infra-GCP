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
        scopes = ["cloud-platform"]  # adjust scopes if needed per-instance later
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
      metadata                 = {
        for k, v in try(inst.metadata, {}) : k => v
        if !contains(["startup-script", "shutdown-script"], k)
      }

      can_ip_forward       = try(inst.can_ip_forward, false)
      deletion_protection  = try(inst.deletion_protection, false)

      confidential_instance_config = try(inst.confidential_instance_config, {})
      shielded_instance_config     = try(inst.shielded_instance_config, {})

      guest_accelerator = try(inst.guest_accelerator, [])
    }
  }

  depends_on = [module.vpcs, module.firewalls, module.iam_bindings]
}

module "gke_clusters" {
  source = "./module/gke"

  project_id = var.project_id
  labels     = try(local.config.labels, {})

  clusters = {
    for name, cluster in try(local.config.gke_clusters, {}) :
    name => {
      location    = cluster.location
      description = try(cluster.description, null)

      network    = cluster.network
      subnetwork = cluster.subnetwork

      ip_allocation_policy = try(cluster.ip_allocation_policy, null)

      release_channel = try(cluster.release_channel, "REGULAR")

      private_cluster_config = try(cluster.private_cluster_config, {})

      master_authorized_networks_config = try(cluster.master_authorized_networks_config, {})

      workload_identity_config = try(cluster.workload_identity_config, {
        workload_pool = "${var.project_id}.svc.id.goog"
      })

      logging_config = try(cluster.logging_config, {
        enable_system_components   = true
        enable_workload_components = false
      })

      monitoring_config = try(cluster.monitoring_config, {
        enable_system_components  = true
        enable_managed_prometheus = false
      })

      cost_management_config = try(cluster.cost_management_config, { enabled = false })

      addons_config = try(cluster.addons_config, {})

      maintenance_policy = try(cluster.maintenance_policy, {
        daily_maintenance_window = { start_time = "03:00" }
      })

      enable_autopilot = try(cluster.enable_autopilot, false)

      node_pools = try(cluster.node_pools, {})
    }
  }

  depends_on = [module.vpcs, module.firewalls, module.nat, module.iam_bindings]
}