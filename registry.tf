module "artifact_registry" {
  for_each = try(local.config.artifact_registries, {})

  source = "./module/artifact_registry"

  providers = {
    google-beta = google-beta
  }

  project_id      = var.project_id
  location        = each.value.location
  repository_id   = each.value.repository_id
  description     = try(each.value.description, "")
  immutable_tags  = try(each.value.immutable_tags, true)
  cleanup_policies = try(each.value.cleanup_policies, {})
  labels          = try(each.value.labels, { environment = "test" })
}