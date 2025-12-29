resource "google_dns_managed_zone" "zone" {
  name        = var.zone_name
  dns_name    = var.dns_name  # e.g., "example.com." or "internal.example.com."
  description = var.description
  project     = var.project_id

  visibility = var.visibility  # "public" or "private"
  # Public zone options (free features)
  dynamic "dnssec_config" {
    for_each = var.visibility == "public" && var.dnssec_enabled ? [1] : []
    content {
      state         = "on"
      default_key_specs {
        algorithm  = "rsasha256"
        key_type   = "keySigning"
        key_length = 2048
      }
      default_key_specs {
        algorithm  = "rsasha256"
        key_type   = "zoneSigning"
        key_length = 1024
      }
    }
  }

  # Private zone visibility (required for private)
  dynamic "private_visibility_config" {
    for_each = var.visibility == "private" ? [1] : []
    content {
      dynamic "networks" {
        for_each = var.private_visibility_networks
        content {
          network_url = networks.value
        }
      }
    }
  }

  labels = var.labels
}

# Optional: Add record sets directly in the zone
resource "google_dns_record_set" "records" {
  for_each = var.recordsets

  name         = each.value.name != "" ? "${each.value.name}.${google_dns_managed_zone.zone.dns_name}" : google_dns_managed_zone.zone.dns_name
  type         = each.value.type
  ttl          = each.value.ttl
  rrdatas      = each.value.rrdatas
  managed_zone = google_dns_managed_zone.zone.name
  project      = var.project_id
}