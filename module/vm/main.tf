locals {
  instance_labels = {
    for name, inst in var.instances :
    name => merge(var.labels, inst.extra_labels)
  }
}

resource "google_compute_disk" "additional" {
  for_each = {
    for pair in flatten([
      for inst_name, inst in var.instances : [
        for idx, disk in inst.disks :
        {
          key       = "${inst_name}-${disk.device_name}"
          inst_name = inst_name
          disk      = disk
          idx       = idx
        }
        if !disk.boot
      ]
    ]) : pair.key => pair
  }

  project = var.project_id
  name    = "${each.value.inst_name}-${each.value.disk.device_name}"
  zone    = var.instances[each.value.inst_name].zone
  size    = try(each.value.disk.initialize_params.size_gb, null)
  type    = try(each.value.disk.initialize_params.type, "pd-balanced")
  image   = try(each.value.disk.initialize_params.image, null)
  labels  = try(each.value.disk.initialize_params.labels, {})
}

resource "google_compute_instance" "vm" {
  for_each = var.instances

  project      = var.project_id
  name         = each.key
  zone         = each.value.zone
  machine_type = each.value.machine_type
  description  = each.value.description
  tags         = each.value.tags
  labels       = local.instance_labels[each.key]

  can_ip_forward      = each.value.can_ip_forward
  deletion_protection = each.value.deletion_protection

  dynamic "confidential_instance_config" {
    for_each = each.value.confidential_instance_config.enable_confidential_compute == true ? [1] : []
    content {
      enable_confidential_compute = true
    }
  }

  dynamic "shielded_instance_config" {
    for_each = [each.value.shielded_instance_config]
    content {
      enable_secure_boot          = shielded_instance_config.value.enable_secure_boot
      enable_vtpm                 = shielded_instance_config.value.enable_vtpm
      enable_integrity_monitoring = shielded_instance_config.value.enable_integrity_monitoring
    }
  }

  dynamic "guest_accelerator" {
    for_each = each.value.guest_accelerator
    content {
      type  = guest_accelerator.value.type
      count = guest_accelerator.value.count
    }
  }

  boot_disk {
    auto_delete = try([for d in each.value.disks : d.auto_delete if d.boot][0], true)
    device_name = [for d in each.value.disks : d.device_name if d.boot][0]

    initialize_params {
      image  = try([for d in each.value.disks : d.initialize_params.image if d.boot][0], null)
      size   = try([for d in each.value.disks : d.initialize_params.size_gb if d.boot][0], null)
      type   = try([for d in each.value.disks : d.initialize_params.type if d.boot][0], "pd-balanced")
      labels = try([for d in each.value.disks : d.initialize_params.labels if d.boot][0], {})
    }
  }

  dynamic "attached_disk" {
    for_each = { for disk in each.value.disks : disk.device_name => disk if !disk.boot }
    content {
      source      = google_compute_disk.additional["${each.key}-${attached_disk.value.device_name}"].self_link
      device_name = attached_disk.value.device_name
      mode        = attached_disk.value.mode
    }
  }

  dynamic "network_interface" {
    for_each = each.value.network_interfaces
    content {
      subnetwork = network_interface.value.subnetwork
      network_ip = network_interface.value.network_ip

      dynamic "access_config" {
        for_each = network_interface.value.access_configs
        content {
          nat_ip       = access_config.value.nat_ip
          network_tier = access_config.value.network_tier
        }
      }

      dynamic "alias_ip_range" {
        for_each = network_interface.value.alias_ip_ranges
        content {
          ip_cidr_range         = alias_ip_range.value.ip_cidr_range
          subnetwork_range_name = alias_ip_range.value.subnetwork_range_name
        }
      }
    }
  }

  metadata = merge(
    each.value.metadata,
    each.value.metadata_startup_script != null ? { "startup-script" = each.value.metadata_startup_script } : {},
    each.value.metadata_shutdown_script != null ? { "shutdown-script" = each.value.metadata_shutdown_script } : {}
  )

  dynamic "service_account" {
    for_each = try([each.value.service_account], [])
    content {
      email  = service_account.value.email
      scopes = service_account.value.scopes
    }
  }

  depends_on = [google_compute_disk.additional]
}