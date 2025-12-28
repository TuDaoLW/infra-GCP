resource "google_compute_global_address" "psa_range" {
  name          = "${var.vpc_name}-psa-range"
  project       = var.project_id
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 20  # /20 = plenty for multiple services/regions
  network       = var.network_self_link
}

resource "google_service_networking_connection" "psa_peering" {
  network                 = var.network_self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.psa_range.name]

  depends_on = [google_compute_global_address.psa_range]
}