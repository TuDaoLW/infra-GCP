resource "google_compute_router" "router" {
  for_each = var.routers

  name    = each.key
  project = var.project_id
  region  = var.region
  network = var.network_self_link
  description = each.value.description

  # BGP block optional - add if needed later (e.g., for VPN/Interconnect)
  # bgp { ... }
}

resource "google_compute_router_nat" "nat" {
  for_each = var.nat_gateways

  name    = each.key
  project = var.project_id
  region  = var.region
  router  = google_compute_router.router[each.value.router_name].name

  nat_ip_allocate_option             = upper(each.value.nat_ip_allocation_mode)
  nat_ips                            = each.value.nat_ips

  source_subnetwork_ip_ranges_to_nat = upper(each.value.source_subnetwork_ip_ranges_to_nat)

  dynamic "subnetwork" {
    for_each = each.value.subnetworks
    content {
      name                     = subnetwork.value.name
      source_ip_ranges_to_nat  = subnetwork.value.source_ip_ranges_to_nat
    }
  }

  dynamic "log_config" {
    for_each = each.value.log_config != null ? [each.value.log_config] : []
    content {
      enable = log_config.value.enable
      filter = upper(log_config.value.filter)
    }
  }

  min_ports_per_vm                    = each.value.min_ports_per_vm
  icmp_idle_timeout_sec               = each.value.icmp_idle_timeout_sec
  tcp_established_idle_timeout_sec    = each.value.tcp_established_idle_timeout_sec
  tcp_transitory_idle_timeout_sec     = each.value.tcp_transitory_idle_timeout_sec
  udp_idle_timeout_sec                = each.value.udp_idle_timeout_sec

  depends_on = [google_compute_router.router]
}