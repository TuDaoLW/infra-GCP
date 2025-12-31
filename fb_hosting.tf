module "firebase_hosting" {
  for_each = try(local.config.firebase_hosting_sites, {})

  source = "./module/fb_hosting"

  providers = {
    google-beta = google-beta
  }

  project_id      = var.project_id
  site_id         = each.value.site_id
  region          = try(each.value.region, "asia-southeast1")
  custom_domain   = try(each.value.custom_domain, null)
  release_message = try(each.value.release_message, null)
  hosting_config  = try(each.value.hosting_config, null)
  cloudrun_dependency = try(module.cloudrun[each.key], null)  # Optional safety
}