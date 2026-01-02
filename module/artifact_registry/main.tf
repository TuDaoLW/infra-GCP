resource "google_artifact_registry_repository" "repo" {
  provider = google-beta

  project       = var.project_id
  location      = var.location
  repository_id = var.repository_id
  format        = "DOCKER"
  description   = var.description

  cleanup_policy_dry_run = false # Active deletion (not dry-run)

  docker_config {
    immutable_tags = var.immutable_tags
  }

  dynamic "cleanup_policies" {
    for_each = var.cleanup_policies
    content {
      id     = cleanup_policies.key
      action = cleanup_policies.value.action

      # Condition - only if present
      dynamic "condition" {
        for_each = try(cleanup_policies.value.condition, null) != null ? [cleanup_policies.value.condition] : []
        content {
          tag_state             = try(condition.value.tag_state, null)
          tag_prefixes          = try(condition.value.tag_prefixes, null)
          version_name_prefixes = try(condition.value.version_name_prefixes, null)
          older_than            = try(condition.value.older_than, null)
        }
      }

      # Most recent versions - only if present
      dynamic "most_recent_versions" {
        for_each = try(cleanup_policies.value.most_recent_versions, null) != null ? [cleanup_policies.value.most_recent_versions] : []
        content {
          keep_count = most_recent_versions.value.keep_count
        }
      }
    }
  }

  labels = var.labels
}
