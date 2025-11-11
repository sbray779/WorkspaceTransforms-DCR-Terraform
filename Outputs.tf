output "dcr_id" {
  description = "Resource ID of the data collection rule."
  value       = azurerm_monitor_data_collection_rule.dcr.id
}

output "dcr_name" {
  description = "Name of the data collection rule."
  value       = azurerm_monitor_data_collection_rule.dcr.name
}

output "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace."
  value       = var.log_analytics_workspace_id
}