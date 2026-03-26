# Import Workflows to n8n
# Usage: .\scripts\import-workflows.ps1

$N8N_URL = 'http://localhost:5678'
$WORKFLOWS_PATH = 'C:\Cindy-OC'

Write-Host '=== Importing workflows to n8n ===' -ForegroundColor Cyan

# Workflow files to import
$workflows = @(
    "$WORKFLOWS_PATH\workflow_simple.json",
    "$WORKFLOWS_PATH\workflow_rescue.json"
)

foreach ($workflowFile in $workflows) {
    if (Test-Path $workflowFile) {
        Write-Host "`nImporting: $workflowFile" -ForegroundColor Yellow
        
        $workflow = Get-Content $workflowFile -Raw | ConvertFrom-Json
        Write-Host "  Name: $($workflow.name)"
        Write-Host "  Nodes: $($workflow.nodes.Count)"
        
        # Create workflow via API
        $body = @{
            name = $workflow.name
            nodes = $workflow.nodes
            connections = $workflow.connections
            settings = $workflow.settings
            active = $false
        } | ConvertTo-Json -Depth 10
        
        try {
            $response = Invoke-RestMethod -Uri "$N8N_URL/rest/workflows" -Method POST -ContentType 'application/json' -Body $body
            Write-Host "  Created workflow ID: $($response.id)" -ForegroundColor Green
        }
        catch {
            Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    else {
        Write-Host "`nSkipping (not found): $workflowFile" -ForegroundColor Gray
    }
}

Write-Host "`n=== Import complete ===" -ForegroundColor Cyan
Write-Host 'Open n8n at:' $N8N_URL -ForegroundColor White
