output "cluster_id" {
  value = google_container_cluster.cluster.id
}

output "cluster_name" {
  value = google_container_cluster.cluster.name
}

output "endpoint" {
  value = google_container_cluster.cluster.endpoint
}

output "master_version" {
  value = google_container_cluster.cluster.master_version
}

output "ca_certificate" {
  value     = google_container_cluster.cluster.master_auth[0].cluster_ca_certificate
  sensitive = true
}