# add outputs here
// filename: outputs.tf

output "cluster_name" { value = google_container_cluster.this.name }
output "endpoint" { value = google_container_cluster.this.endpoint }
output "ca_certificate" { value = google_container_cluster.this.master_auth[0].cluster_ca_certificate }
output "location" { value = google_container_cluster.this.location }
output "node_pool_name" { value = google_container_node_pool.default.name }

