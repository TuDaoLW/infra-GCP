resource "google_firebase_hosting_site" "site" {
  provider = google-beta
  project  = var.project_id
  site_id  = var.site_id
}

resource "google_firebase_hosting_version" "version" {
  provider = google-beta
  site_id  = google_firebase_hosting_site.site.site_id

  dynamic "config" {
    for_each = var.hosting_config != null ? [var.hosting_config] : []
    content {
      # Rewrites section — always included if present
      dynamic "rewrites" {
        for_each = try(var.hosting_config.rewrites, [])
        content {
          glob  = try(rewrites.value.glob, null)
          regex = try(rewrites.value.regex, null)

          dynamic "run" {
            for_each = try(rewrites.value.run, null) != null ? [rewrites.value.run] : []
            content {
              service_id = rewrites.value.run.service_id
              region     = try(rewrites.value.run.region, var.region)
            }
          }

          path     = try(rewrites.value.path, null)
          function = try(rewrites.value.function, null)
        }
      }

      # Redirects section — only if provided
      dynamic "redirects" {
        for_each = try(var.hosting_config.redirects, null) != null ? var.hosting_config.redirects : []
        content {
          glob        = redirects.value.glob
          regex       = try(redirects.value.regex, null)
          location    = redirects.value.location
          status_code = redirects.value.status_code
        }
      }

      # Headers section — only if provided
      dynamic "headers" {
        for_each = try(var.hosting_config.headers, null) != null ? var.hosting_config.headers : []
        content {
          glob    = headers.value.glob
          regex   = try(headers.value.regex, null)
          headers = headers.value.headers
        }
      }
    }
  }

  depends_on = [var.cloudrun_dependency]
}

resource "google_firebase_hosting_release" "release" {
  provider     = google-beta
  site_id      = google_firebase_hosting_site.site.site_id
  version_name = google_firebase_hosting_version.version.name
  message      = try(var.release_message, "Deployed via Terraform")
}

resource "google_firebase_hosting_custom_domain" "domain" {
  count         = var.custom_domain != null ? 1 : 0
  provider      = google-beta
  project       = var.project_id
  site_id       = google_firebase_hosting_site.site.site_id
  custom_domain = var.custom_domain
}