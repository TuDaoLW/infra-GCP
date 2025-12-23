resource "google_compute_network" "vpc" {
  name                            = var.name
  project                         = var.project_id
  auto_create_subnetworks         = var.auto_create_subnetworks
  routing_mode                    = upper(var.routing_mode)
  mtu                             = var.mtu
  description                     = var.description
  delete_default_routes_on_create = false
}

resource "google_compute_subnetwork" "subnets" {
  for_each = { for s in var.subnets : "${s.region}/${s.name}" => s }

  name                     = each.value.name
  project                  = var.project_id
  network                  = google_compute_network.vpc.self_link
  region                   = each.value.region
  ip_cidr_range            = each.value.ip_cidr_range
  private_ip_google_access = each.value.private_ip_google_access
  description              = each.value.description
  purpose                  = each.value.purpose
  role                     = each.value.role

  dynamic "secondary_ip_range" {
    for_each = each.value.secondary_ip_ranges
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }
  depends_on = [google_compute_network.vpc]
}
