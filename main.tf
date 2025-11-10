#Random string to use for destination name
resource "random_string" "destination_name" {
  length  = 32
  upper   = false
  special = false
}

# Data Collection Rule (WorkspaceTransforms)
resource "azurerm_monitor_data_collection_rule" "dcr" {
  name                = var.dcr_name
  resource_group_name = var.resource_group_name
  location            = var.location

  # Matches ARM: kind = "WorkspaceTransforms"
  kind = "WorkspaceTransforms"

  # For WorkspaceTransforms DCRs, data_sources must be present but empty
  data_sources {}

  destinations {
    log_analytics {
      # This is the friendly destination name within the DCR; can be any unique string.
      name                  = resource.random_string.destination_name.result
      workspace_resource_id = var.log_analytics_workspace_id
    }
  }

  # Data flow mapping the table stream to the destination with a KQL transform
  # Note: For workspace transformations, the stream should match the table name
  data_flow {
    streams      = ["Microsoft-Table-ApiManagementGatewayLlmLog"]
    destinations = [resource.random_string.destination_name.result]

    transform_kql = <<-KQL
      source
      | project
          TimeGenerated,
          Region,
          CorrelationId,
          SequenceNumber,
          IsStreamCompletion,
          ModelName,
          PromptTokens,
          CompletionTokens,
          TotalTokens
    KQL
  }
}