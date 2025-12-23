locals {
  config_path  = "${path.module}/config/${var.env}"
  config_files = fileset(local.config_path, "*.yaml")
  config       = merge([for f in local.config_files : yamldecode(file("${local.config_path}/${f}"))]...)
}
