output "service_url" {
  description = "The HTTPS URL of the Cloud Run service"
  value       = google_cloud_run_v2_service.service.uri
}

output "service_id" {
  description = "The full ID of the service"
  value       = google_cloud_run_v2_service.service.id
}

output "service_name" {
  description = "Name of the deployed service"
  value       = google_cloud_run_v2_service.service.name
}

output "location" {
  description = "Region/location of the service"
  value       = google_cloud_run_v2_service.service.location
}