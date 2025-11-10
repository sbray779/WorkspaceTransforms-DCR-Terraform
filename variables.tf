variable "resource_group_name" {
  description = "Resource group where the DCR will be created."
  type        = string
}

variable "location" {
  description = "Azure region for the DCR."
  type        = string
  default     = "eastus2"
}

variable "dcr_name" {
  description = "Name of the Data Collection Rule."
  type        = string
  default     = "ParseLLM2" # from ARM default
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace (e.g., /subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.OperationalInsights/workspaces/<name>)."
  type        = string
}

variable "subscription_id" {
  description = "Azure Subscription ID."
  type        = string
}