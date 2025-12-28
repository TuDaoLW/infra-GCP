output "services" {
  description = "Map of created Cloud Run services with useful details"
  value = { for k, s in google_cloud_run_v2_service.service :
    k => {
      id           = s.id
      name         = s.name
      location     = s.location
      uri          = s.uri
      template     = s.template
      traffic      = s.traffic
      labels       = s.labels
    }
  }
}

output "service_uris" {
  description = "Map of service name => default URL"
  value = { for k, s in google_cloud_run_v2_service.service : k => s.uri }
}