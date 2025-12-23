output "vpc_id" {
  value = google_compute_network.vpc.id
}

output "vpc_self_link" {
  value = google_compute_network.vpc.self_link
}

output "subnets" {
  description = "Map of created subnets with details including tags for firewall use"
  value = { for k, s in google_compute_subnetwork.subnets :
    k => {
      id               = s.id
      self_link        = s.self_link
      gateway_address  = s.gateway_address
      secondary_ranges = s.secondary_ip_range
      tags             = var.subnets[index(var.subnets.*.name, s.name)].tags # Pass through tags
    }
  }
}

output "subnet_tags_map" {
  description = "Map of subnet name => list of network tags (useful for firewall module)"
  value = {
    for s in var.subnets : s.name => s.tags
  }
}
