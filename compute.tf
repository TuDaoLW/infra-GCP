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
        scopes = ["cloud-platform"] # adjust scopes if needed per-instance later
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
