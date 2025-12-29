output "name_servers" {
  description = "Name servers for public zones — copy these to your registrar"
  value       = var.visibility == "public" ? google_dns_managed_zone.zone.name_servers : null
}

output "zone_name" {
  value = google_dns_managed_zone.zone.name
}

output "dns_name" {
  value = google_dns_managed_zone.zone.dns_name
}