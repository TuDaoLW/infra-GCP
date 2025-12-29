module "cloudrun" {
  for_each = try(local.config.cloudrun_services, {})

  source = "./module/cloudrun"

  service_name = each.key
  project_id   = var.project_id
  region       = try(each.value.region, "asia-southeast1")
  description  = try(each.value.description, "")

  container_image       = each.value.container_image
  container_port        = try(each.value.container_port, 80)
  max_concurrency       = try(each.value.max_concurrency, 200)
  cpu_limit             = try(each.value.cpu_limit, "1")
  memory_limit          = try(each.value.memory_limit, "512Mi")
  request_based_billing = try(each.value.request_based_billing, true)
  min_instances         = try(each.value.min_instances, 0)
  max_instances         = try(each.value.max_instances, 100)

  service_account_email = each.value.service_account_email

  env_vars = try(each.value.env_vars, {})
  secrets  = try(each.value.secrets, {})

  direct_vpc_enabled   = try(each.value.direct_vpc_enabled, false)
  network_self_link    = try(each.value.network_self_link, module.vpcs["sample-vpc"].vpc_self_link)
  subnetwork_self_link = try(each.value.subnetwork_self_link, null)
  network_tags         = try(each.value.network_tags, [])
  vpc_egress_setting   = try(each.value.vpc_egress_setting, "PRIVATE_RANGES_ONLY")
  ingress              = try(each.value.ingress, "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER_ONLY")
  # default_uri_disabled = try(each.value.default_uri_disabled, true)
  allow_unauthenticated = try(each.value.allow_unauthenticated, true)
  custom_domain         = try(each.value.custom_domain, null)
  depends_on            = [module.iam_bindings]
}
