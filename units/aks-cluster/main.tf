# An AKS cluster with the simplest possible configuration:
#   - SystemAssigned identity (Azure manages credentials — no service principal to create)
#   - A single default node pool (where both system pods and your workloads run)
#   - No custom networking (Azure creates a VNet automatically)
#   - No autoscaling (fixed node count)

resource "azurerm_kubernetes_cluster" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  tags                = var.tags

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = var.node_pool_vm_size
  }
}
