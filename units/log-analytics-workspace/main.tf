resource "azurerm_log_analytics_workspace" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"  # Only SKU that supports all features; others are legacy
  retention_in_days   = var.retention_in_days
  tags                = var.tags
}
