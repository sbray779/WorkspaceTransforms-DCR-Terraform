#!/bin/bash

# Get DCR ID and Workspace ID from Terraform output
if command -v terraform &> /dev/null; then
    DCR_ID=$(terraform output -raw dcr_id 2>/dev/null)
    WORKSPACE_ID=$(terraform output -raw log_analytics_workspace_id 2>/dev/null)
    
    # Check if we successfully got both resource IDs
    if [ -z "$DCR_ID" ] || [ -z "$WORKSPACE_ID" ]; then
        echo " Error: Failed to retrieve resource IDs from Terraform output."
        echo "   Make sure you have run 'terraform apply' successfully."
        echo "   Expected outputs: dcr_id, log_analytics_workspace_id"
        exit 1
    fi
else
    echo " Error: Terraform is not available or not in PATH."
    echo "   This script requires Terraform to retrieve resource IDs."
    echo "   Please install Terraform and ensure it's accessible from the command line."
    exit 1
fi

echo "Using DCR ID: $DCR_ID"
echo "Using Workspace ID: $WORKSPACE_ID"

# Create temporary JSON file
TEMP_JSON=$(mktemp)
cat > "$TEMP_JSON" << EOF
{
  "properties": {
    "defaultDataCollectionRuleResourceId": "$DCR_ID"
  }
}
EOF

echo "Setting workspace default DCR..."

# Read the JSON content and pass it directly
JSON_BODY=$(cat "$TEMP_JSON")

# Set the workspace as default DCR using JSON content
az rest --method PATCH \
  --url "${WORKSPACE_ID}?api-version=2021-12-01-preview" \
  --headers "Content-Type=application/json" \
  --body "$JSON_BODY"

RESULT=$?

# Clean up temp file
rm -f "$TEMP_JSON"

if [ $RESULT -eq 0 ]; then
    echo "Successfully set workspace default DCR!"
else
    echo "Failed to set workspace default DCR"
    exit 1
fi