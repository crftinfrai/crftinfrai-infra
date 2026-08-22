# add outputs here
// filename: outputs.tf

output "cluster_name" { value = azurerm_kubernetes_cluster.this.name }
output "fqdn" { value = azurerm_kubernetes_cluster.this.fqdn }
output "private_fqdn" { value = try(azurerm_kubernetes_cluster.this.private_fqdn, null) }
output "kube_admin_config" {
  value = {
    host                   = azurerm_kubernetes_cluster.this.kube_admin_config[0].host
    client_certificate     = azurerm_kubernetes_cluster.this.kube_admin_config[0].client_certificate
    client_key             = azurerm_kubernetes_cluster.this.kube_admin_config[0].client_key
    cluster_ca_certificate = azurerm_kubernetes_cluster.this.kube_admin_config[0].cluster_ca_certificate
  }
  sensitive = true
}

