output "name" {
  value = azurerm_kubernetes_cluster.this.name
}

output "id" {
  value = azurerm_kubernetes_cluster.this.id
}

output "kube_config_raw" {
  description = "Raw kubeconfig for kubectl. Use: terragrunt output -raw kube_config_raw > ~/.kube/config"
  value       = azurerm_kubernetes_cluster.this.kube_config_raw
  sensitive   = true
}

output "fqdn" {
  description = "The FQDN of the Kubernetes API server."
  value       = azurerm_kubernetes_cluster.this.fqdn
}
