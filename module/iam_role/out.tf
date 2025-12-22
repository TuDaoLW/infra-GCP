output "service_accounts" {
  description = "Map of created service accounts"
  value = { for k, sa in google_service_account.sa :
    k => {
      email = sa.email
      name  = sa.name
    }
  }
}

output "custom_role_ids" {
  description = "Map of custom role full IDs (projects/{{project}}/roles/{{role_id}})"
  value = { for k, r in google_project_iam_custom_role.custom :
    k => r.id
  }
}