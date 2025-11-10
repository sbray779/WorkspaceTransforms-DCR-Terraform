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
├── .gitignore                 # Git ignore rules
└── README.md                  # This file
```

## Security Notes

- The `terraform.tfvars` file contains sensitive information and is excluded from version control
- Use Azure Key Vault or environment variables for sensitive values in production
- Follow the principle of least privilege when assigning Azure permissions

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