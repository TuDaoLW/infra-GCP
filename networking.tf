module "vpcs" {
  for_each = try(local.config.vpc_networks, {})

  source = "./module/vpc"

  name                    = each.key  # Now using the map key as name
  project_id              = var.project_id
  auto_create_subnetworks = try(each.value.auto_create_subnetworks, false)
  routing_mode            = try(each.value.routing_mode, "REGIONAL")
  mtu                     = try(each.value.mtu, null)
  description             = try(each.value.description, null)
  tags                    = try(each.value.tags, [])

  subnets                 = each.value.subnets
}

module "nat" {
  for_each = try(local.config.cloud_nat_gateways, {})

  source = "./module/nat"

  project_id        = var.project_id
  region            = each.value.region 
  network_self_link = module.vpcs[each.value.vpc_name].vpc_self_link

  routers      = try(local.config.cloud_routers, {})
  nat_gateways = { (each.key) = each.value } 
}