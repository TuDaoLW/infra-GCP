output "site_id" {
  value       = google_firebase_hosting_site.site.site_id
  description = "Firebase Hosting site ID"
}

output "hosting_url" {
  value       = "https://${google_firebase_hosting_site.site.site_id}.web.app"
  description = "Default Firebase Hosting URL (for testing)"
}