module "vpcs" {
  for_each = try(local.config.vpc_networks, {})

  source = "./module/vpc"

  name                    = each.key
  project_id              = var.project_id
  auto_create_subnetworks = try(each.value.auto_create_subnetworks, false)
  routing_mode            = try(each.value.routing_mode, "REGIONAL")
  mtu                     = try(each.value.mtu, null)
  description             = try(each.value.description, null)
  tags                    = try(each.value.tags, [])
  subnets                 = try(each.value.subnets, [])
}

module "psa" {
  for_each = module.vpcs  # One per VPC

  source = "./module/psa"

  project_id        = var.project_id
  vpc_name          = each.key
  network_self_link = each.value.vpc_self_link
}

module "nat" {
  for_each = try(local.config.cloud_nat_gateways, {})

  source     = "./module/nat"
  project_id = var.project_id
  region     = each.value.region

  network_self_link = module.vpcs[each.value.vpc_name].vpc_self_link

  routers      = try(local.config.cloud_routers, {})
  nat_gateways = { (each.key) = each.value }
}

module "firewalls" {
  for_each = length(try(local.config.firewall_rules, {})) > 0 ? { for vpc_name, _ in try(local.config.vpc_networks, {}) : vpc_name => true } : {}

  source            = "./module/firewall"
  project_id        = var.project_id
  network_self_link = module.vpcs[each.key].vpc_self_link
  rules             = try(local.config.firewall_rules, {})
}