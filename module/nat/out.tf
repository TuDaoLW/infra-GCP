output "routers" {
  description = "Map of created Cloud Routers"
  value = { for k, r in google_compute_router.router :
    k => {
      id        = r.id
      self_link = r.self_link
    }
  }
}

output "nat_gateways" {
  description = "Map of created Cloud NAT gateways"
  value = { for k, n in google_compute_router_nat.nat :
    k => {
      id = n.id
      # No self_link available - use id instead (full resource identifier)
    }
  }
}
