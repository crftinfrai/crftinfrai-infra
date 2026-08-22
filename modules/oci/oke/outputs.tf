# add outputs here
// filename: outputs.tf

output "cluster_id" { value = oci_containerengine_cluster.this.id }
output "k8s_version" { value = oci_containerengine_cluster.this.kubernetes_version }
output "node_pool_id" { value = oci_containerengine_node_pool.default.id }
output "node_subnet_id" { value = local.node_subnet_id }
output "lb_subnet_id" { value = local.lb_subnet_id }

