module "iam" {
  source = "./module/iam_role"

  project_id = var.project_id

  service_accounts = try(local.config.service_accounts, {})

  custom_roles = try(local.config.iam_roles, {})

  role_bindings = try(local.config.iam_role_bindings, {})
}

# New: Local map to resolve custom role IDs using the module output
locals {
  custom_role_map = module.iam.custom_role_ids
}

# Separate module for bindings to resolve custom roles properly
module "iam_bindings" {
  source = "./module/iam_role" # Reuse same module, but only for bindings

  project_id = var.project_id

  service_accounts = {} # No SAs
  custom_roles     = {} # No custom roles

  role_bindings = {
    for k, v in try(local.config.iam_role_bindings, {}) :
    k => {
      role = startswith(v.role, "projects/") || startswith(v.role, "roles/") == false ? try(local.custom_role_map[split("/", v.role)[3]], v.role) : v.role # Predefined role (e.g., roles/storage.objectViewer)

      members       = v.members
      resource_id   = v.resource_id
      resource_type = v.resource_type
      description   = try(v.description, null)
      condition     = try(v.condition, null)
      extra_labels  = try(v.extra_labels, {})
    }
  }

  depends_on = [module.iam] # Ensure custom roles exist before bindings
}
