# Azure Data Collection Rule (DCR) for WorkspaceTransforms

This Terraform module creates an Azure Monitor Data Collection Rule (DCR) with WorkspaceTransforms kind for applying transformations to log data in a Log Analytics workspace.

## Overview

The DCR applies KQL transformations to incoming data for the `ApiManagementGatewayLlmLog` table, filtering and projecting specific columns to optimize storage and query performance.

## Features

- **WorkspaceTransforms DCR**: Applies transformations directly to workspace tables
- **KQL Transformation**: Filters and projects specific columns from log data
- **Cost Optimization**: Reduces storage requirements by selecting only needed columns

## Prerequisites

- Azure subscription with appropriate permissions
- Log Analytics workspace
- Terraform >= 1.5.0
- Azure CLI or other authentication method configured

## Usage

1. **Clone and Configure**:
   ```bash
   git clone <repository-url>
   cd DCRWorkspaceTable
   ```

2. **Set up Variables**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your actual values
   ```

3. **Initialize and Deploy**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Configuration

### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `resource_group_name` | Resource group for the DCR | `"rg-monitoring-prod"` |
| `location` | Azure region | `"eastus2"` |
| `dcr_name` | Name of the DCR | `"ParseLLMGatewayLogs"` |
| `log_analytics_workspace_id` | Full resource ID of the workspace | `"/subscriptions/.../workspaces/workspace-name"` |
| `subscription_id` | Azure subscription ID | `"00000000-0000-0000-0000-000000000000"` |

### Transformation Logic

The DCR applies the following transformation to incoming data:

```kql
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
```

This transformation:
- Selects only the specified columns
- Filters out unnecessary data to reduce storage costs
- Maintains essential fields for analysis and monitoring

## Outputs

| Output | Description |
|--------|-------------|
| `dcr_id` | Full resource ID of the created DCR |
| `dcr_name` | Name of the DCR |

## File Structure

```
├── main.tf                    # Main DCR resource definition
├── variables.tf               # Variable definitions
├── Outputs.tf                 # Output definitions
├── Providers.tf               # Provider configuration
├── terraform.tfvars.example   # Example variables file
├── LinkDCR.ps1                # PowerShell script to link DCR to workspace
├── LinkDCR.sh                 # Bash script to link DCR to workspace (in Scripts folder)
├── .gitignore                 # Git ignore rules
└── README.md                  # This file
```

## Security Notes

- The `terraform.tfvars` file contains sensitive information and is excluded from version control
- Use Azure Key Vault or environment variables for sensitive values in production
- Follow the principle of least privilege when assigning Azure permissions

## Linking DCR to Workspace

After deploying the DCR with Terraform, you need to associate it with the Log Analytics workspace for the transformations to take effect. The repository includes scripts to automate this process.

### Automated Scripts (Recommended)

#### **PowerShell Script**
```powershell
.\LinkDCR.ps1
```
- Automatically reads DCR ID and Workspace ID from Terraform outputs
- Handles JSON formatting and Azure CLI execution
- Provides detailed error messages and validation

#### **Bash Script**
```bash
./LinkDCR.sh
```
- Cross-platform compatible (Linux/macOS/WSL)
- Same functionality as PowerShell script
- Requires Terraform to be available in bash environment

### Manual Command (Alternative)

If you prefer to run the command manually or need to customize it:

```powershell
# Using CMD from PowerShell (handles JSON escaping properly)
cmd /c 'az rest --method PATCH --url "https://management.azure.com/subscriptions/{SUBSCRIPTION_ID}/resourceGroups/{RESOURCE_GROUP_NAME}/providers/Microsoft.OperationalInsights/workspaces/{WORKSPACE_NAME}?api-version=2021-12-01-preview" --headers "Content-Type=application/json" --body "{\"properties\":{\"defaultDataCollectionRuleResourceId\":\"/subscriptions/{SUBSCRIPTION_ID}/resourceGroups/{RESOURCE_GROUP_NAME}/providers/Microsoft.Insights/dataCollectionRules/{DCR_NAME}\"}}"'
```

**Replace the placeholders:**
- `{SUBSCRIPTION_ID}` - Your Azure subscription ID
- `{RESOURCE_GROUP_NAME}` - Resource group name
- `{WORKSPACE_NAME}` - Log Analytics workspace name  
- `{DCR_NAME}` - Data Collection Rule name

### Using Terraform Outputs (Dynamic)

```powershell
$workspaceId = terraform output -raw log_analytics_workspace_id
$dcrId = terraform output -raw dcr_id
cmd /c "az rest --method PATCH --url `"https://management.azure.com$workspaceId?api-version=2021-12-01-preview`" --headers `"Content-Type=application/json`" --body `"{\\`"properties\\`":{\\`"defaultDataCollectionRuleResourceId\\`":\\`"$dcrId\\`"}}`""
```

### Prerequisites for Linking
- Azure CLI installed and authenticated (`az login`)
- `Monitoring Contributor` role or equivalent permissions
- Successful Terraform deployment (scripts read from `terraform output`)

### Important Notes
- **Activation Time**: It can take up to 30 minutes after linking before transformations take effect
- **Validation**: Both scripts verify the DCR and workspace exist before attempting to link them
- **Error Handling**: Scripts provide clear error messages if prerequisites aren't met

For more details, see the [Azure Monitor DCR documentation](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/tutorial-workspace-transformations-api)

## Troubleshooting

### Common Issues

1. **"Data collection rule is invalid" Error**:
   - Ensure the `data_sources {}` block is present for WorkspaceTransforms DCRs
   - Verify the Log Analytics workspace exists and is accessible
   - Check that the stream name matches your table structure

2. **Permission Errors**:
   - Ensure you have `Monitoring Contributor` role or equivalent
   - Verify the service principal has access to the target resource group

3. **Stream Not Found**:
   - Confirm the target table exists in the Log Analytics workspace
   - Verify the stream name format follows Azure conventions

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues and questions:
- Check the [Azure Monitor DCR documentation](https://docs.microsoft.com/en-us/azure/azure-monitor/data-collection/)
- Review Terraform AzureRM provider documentation
- Open an issue in this repository