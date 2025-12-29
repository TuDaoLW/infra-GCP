module "dns_zones" {
  for_each = try(local.config.cloud_dns_zones, {})

  source = "./module/dns"

  project_id                   = var.project_id
  zone_name                    = each.key
  dns_name                     = each.value.dns_name
  description                  = try(each.value.description, "Managed by Terraform")
  visibility                   = each.value.visibility
  dnssec_enabled               = try(each.value.dnssec_enabled, false)
  private_visibility_networks  = try(each.value.private_visibility_networks, [])
  labels                       = try(each.value.labels, { environment = "prod" })
  recordsets                   = try(each.value.recordsets, {})
}

# Easy output for public zones
output "public_zone_nameservers" {
  value = {
    for k, mod in module.dns_zones :
    k => mod.name_servers
    if mod.name_servers != null
  }
  description = "Copy these NS records to your domain registrar"
}