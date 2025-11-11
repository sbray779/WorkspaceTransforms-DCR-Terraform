# PowerShell script to link DCR to workspace as default DCR
# Get DCR ID and Workspace ID from Terraform output
$DcrId = terraform output -raw dcr_id

if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to get DCR ID from Terraform output"
    exit 1
}

$WorkspaceId = terraform output -raw log_analytics_workspace_id

if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to get Workspace ID from Terraform output"
    exit 1
}

Write-Host "Using DCR ID: $DcrId" -ForegroundColor Green
Write-Host "Using Workspace ID: $WorkspaceId" -ForegroundColor Green

# Create a temporary JSON file for the body
$tempFile = [System.IO.Path]::GetTempFileName()
$bodyContent = @"
{
  "properties": {
    "defaultDataCollectionRuleResourceId": "$DcrId"
  }
}
"@

$bodyContent | Out-File -FilePath $tempFile -Encoding UTF8

Write-Host "Setting workspace default DCR..." -ForegroundColor Yellow

# Use the JSON file with az rest
az rest --method PATCH `
  --url "$WorkspaceId?api-version=2021-12-01-preview" `
  --headers "Content-Type=application/json" `
  --body "@$tempFile"

$result = $LASTEXITCODE

# Clean up temp file
Remove-Item $tempFile -Force

if ($result -eq 0) {
    Write-Host "✅ Successfully set workspace default DCR!" -ForegroundColor Green
} else {
    Write-Error "❌ Failed to set workspace default DCR"
}