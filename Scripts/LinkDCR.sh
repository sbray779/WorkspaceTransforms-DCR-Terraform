
SUB="Subscription ID of Workspace"
RG="Resource Group name of workspace"
WORKSPACE="Log Analytics Workspace Name"   # <-- verify actual LAW name
API="2022-10-01"

URI="https://management.azure.com/subscriptions/$SUB/resourceGroups/$RG/providers/Microsoft.OperationalInsights/workspaces/$WORKSPACE?api-version=$API"

cat > body.json <<'JSON'
{
  "properties": {
    "defaultDataCollectionRuleResourceId": "<Resource ID of DCR>"
  }
}
JSON

az rest --method PATCH --url "$URI" --body @body.json
