output "dcr_id" {
  description = "Resource ID of the data collection rule."
  value       = azurerm_monitor_data_collection_rule.dcr.id
}

output "dcr_name" {
  value = azurerm_monitor_data_collection_rule.dcr.name
}