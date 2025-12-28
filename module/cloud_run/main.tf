resource "google_cloud_run_v2_service" "service" {
  for_each = var.cloud_run_services

  name                = each.key
  project             = each.value.project_id
  location            = each.value.location
  description         = try(each.value.description, null)
  ingress             = try(each.value.ingress, "INGRESS_TRAFFIC_ALL")
#   deletion_protection = try(each.value.deletion_protection, false)

  template {
    containers {
      image = each.value.image  # Placeholder image – CI/CD will override

      ports {
        container_port = try(each.value.container.port, 8080)
      }

      dynamic "startup_probe" {
        for_each = try([each.value.container.startup_probe], [])
        content {
          dynamic "http_get" {
            for_each = try([startup_probe.value.http_get], [])
            content {
              path = http_get.value.path
              port = try(http_get.value.port, each.value.container.port)
            }
          }
          timeout_seconds   = try(startup_probe.value.timeout_seconds, 10)
          period_seconds    = try(startup_probe.value.period_seconds, 10)
          failure_threshold = try(startup_probe.value.failure_threshold, 3)
        }
      }

      resources {
        limits = {
          cpu    = each.value.container.cpu
          memory = each.value.container.memory
        }
      }

      dynamic "env" {
        for_each = try(each.value.env_vars, [])
        content {
          name  = env.value.name
          value = env.value.value
        }
      }

      dynamic "env" {
        for_each = try(each.value.secret_env_vars, [])
        content {
          name = env.value.name
          value_source {
            secret_key_ref {
              secret  = env.value.secret
              version = env.value.version
            }
          }
        }
      }
    }

    scaling {
      min_instance_count = each.value.scaling.min_instances
      max_instance_count = each.value.scaling.max_instances
    }

    dynamic "vpc_access" {
      for_each = try([each.value.vpc_access], [])
      content {
        connector = vpc_access.value.connector
        egress    = vpc_access.value.egress
      }
    }

    # Optional: concurrency (set at container level in v2)
    max_instance_request_concurrency = try(each.value.container.concurrency, 80)
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }

  labels = merge(
    try(each.value.extra_labels, {}),
    { managed_by = "terraform" }
  )

  lifecycle {
    ignore_changes = [
      template[0].containers[0].image,  # Let CI/CD handle image deploys
      client,
      client_version,
      launch_stage
    ]
  }
}

# Optional IAM for unauthenticated access (allUsers = public)
resource "google_cloud_run_v2_service_iam_member" "public_invoker" {
  for_each = { for k, v in var.cloud_run_services : k => v if try(v.allow_unauthenticated, false) }

  project  = google_cloud_run_v2_service.service[each.key].project
  location = google_cloud_run_v2_service.service[each.key].location
  name     = google_cloud_run_v2_service.service[each.key].name
  role     = "roles/run.invoker"
  member   = "allUsers"
}