resource "google_compute_firewall" "rules" {
  for_each = var.rules

  name        = each.key
  project     = var.project_id
  network     = var.network_self_link
  direction   = upper(each.value.direction)
  priority    = each.value.priority
  description = each.value.description

  dynamic "allow" {
    for_each = each.value.action == "ALLOW" ? each.value.protocols : []
    content {
      protocol = lower(allow.value.protocol == "all" ? "all" : allow.value.protocol)
      ports    = allow.value.protocol == "all" ? [] : allow.value.ports
    }
  }

  dynamic "deny" {
    for_each = each.value.action == "DENY" ? each.value.protocols : []
    content {
      protocol = lower(deny.value.protocol == "all" ? "all" : deny.value.protocol)
      ports    = deny.value.protocol == "all" ? [] : deny.value.ports
    }
  }

  source_ranges      = each.value.direction == "INGRESS" ? each.value.source_ranges : null
  destination_ranges = each.value.direction == "EGRESS" ? each.value.destination_ranges : null

  target_tags = each.value.target_tags
}
