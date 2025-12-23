output "instances" {
  description = "Map of created instances with key details"
  value = {
    for name, inst in google_compute_instance.vm :
    name => {
      id                 = inst.id
      self_link          = inst.self_link
      instance_id        = inst.instance_id
      network_interfaces = inst.network_interface
      tags               = inst.tags
      labels             = inst.labels
    }
  }
}

output "instance_self_links" {
  description = "Map of instance name => self_link"
  value       = { for name, inst in google_compute_instance.vm : name => inst.self_link }
}

output "instance_network_tags" {
  description = "Map of instance name => list of network tags (useful for firewall rules)"
  value       = { for name, inst in var.instances : name => inst.tags }
}
