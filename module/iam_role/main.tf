# Create Service Accounts
resource "google_service_account" "sa" {
  for_each = var.service_accounts

  project      = var.project_id
  account_id   = each.value.account_id
  display_name = each.value.display_name
  description  = each.value.description
}

# Create Custom Roles (project-level)
resource "google_project_iam_custom_role" "custom" {
  for_each = var.custom_roles

  project     = var.project_id
  role_id     = each.value.role_id
  title       = each.value.title
  description = each.value.description
  stage       = upper(each.value.stage)
  permissions = each.value.permissions
}

# Project-level bindings (supports multiple members + conditions)
resource "google_project_iam_binding" "project_authoritative" {
  for_each = {
    for k, v in var.role_bindings : k => v
    if v.resource_type == "project"
  }

  project = each.value.resource_id
  role    = each.value.role
  members = each.value.members

  dynamic "condition" {
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      title       = condition.value.title
      description = condition.value.description
      expression  = condition.value.expression
    }
  }
}

# Bucket-level bindings (one resource per member)
resource "google_storage_bucket_iam_member" "bucket" {
  for_each = {
    for binding in flatten([
      for k, v in var.role_bindings : [
        for m in v.members : {
          key           = k
          member        = m
          role          = v.role
          bucket        = v.resource_id
          condition     = v.condition
        }
      ]
      if v.resource_type == "bucket"
    ]) : "${binding.key}.${binding.member}" => binding
  }

  bucket = each.value.bucket
  role   = each.value.role
  member = each.value.member

  dynamic "condition" {
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      title       = condition.value.title
      description = condition.value.description
      expression  = condition.value.expression
    }
  }
}

resource "google_service_account_iam_binding" "sa_authoritative" {
  for_each = {
    for k, v in var.role_bindings : k => v
    if v.resource_type == "serviceAccount" &&
       contains(keys(google_service_account.sa), split("@", v.resource_id)[0])
  }

  service_account_id = google_service_account.sa[split("@", each.value.resource_id)[0]].name
  role               = each.value.role
  members            = each.value.members

  dynamic "condition" {
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      title       = condition.value.title
      description = condition.value.description
      expression  = condition.value.expression
    }
  }
}