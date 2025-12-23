output "clusters" {
  description = "Map of created GKE clusters with key details"
  value = {
    for name, cluster in google_container_cluster.cluster :
    name => {
      id                  = cluster.id
      self_link           = cluster.self_link
      endpoint            = cluster.endpoint
      master_version      = cluster.master_version
      node_pools          = google_container_node_pool.pools[*].name
      ca_certificate      = cluster.master_auth.0.cluster_ca_certificate
    }
  }
}

output "cluster_endpoints" {
  value = { for name, c in google_container_cluster.cluster : name => c.endpoint }
}