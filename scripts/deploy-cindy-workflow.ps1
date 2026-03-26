# Deploy Cindy-Telegram-AutoReply to n8n
# Usage: pwsh -ExecutionPolicy Bypass -File scripts/deploy-cindy-workflow.ps1

$N8N_URL = 'http://localhost:5678'
$API_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzMzkwZTNlNC00NWY2LTQ3NjktODNhNi00OWQ0OGQ0MGQ5NTgiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwianRpIjoiYjA4M2UwYTgtM2U4OC00Mzk1LTg2MjktNjU5NGM5ODY3ZGRmIiwiaWF0IjoxNzc0NTUxMjQ1fQ.m0JPROZL7eQ-NHQMPDSiUk35srjEs7uOOvaCw_jbwrk'

Write-Host '=== Deploying Cindy-Telegram-AutoReply ===' -ForegroundColor Cyan

# Load workflow
$workflowPath = 'C:\Cindy-OC\workflow-cindy-telegram-reply.json'
$workflow = Get-Content $workflowPath -Raw | ConvertFrom-Json

Write-Host "Name: $($workflow.name)"
Write-Host "Nodes: $($workflow.nodes.Count)"

# Headers
$headers = @{
    'X-N8N-API-KEY' = $API_KEY
    'Content-Type' = 'application/json'
}

# Create body
$body = @{
    name = $workflow.name
    nodes = $workflow.nodes
    connections = $workflow.connections
    settings = $workflow.settings
    active = $false
} | ConvertTo-Json -Depth 10

# Deploy
try {
    Write-Host 'Deploying to n8n...' -ForegroundColor Yellow
    $response = Invoke-RestMethod -Uri "$N8N_URL/api/v1/workflows" -Method POST -Headers $headers -Body $body
    
    Write-Host "SUCCESS! Workflow ID: $($response.data.id)" -ForegroundColor Green
    Write-Host "Name: $($response.data.name)"
    
    # Now activate
    Write-Host 'Activating workflow...' -ForegroundColor Yellow
    $activateBody = @{ active = $true } | ConvertTo-Json
    $activateResponse = Invoke-RestMethod -Uri "$N8N_URL/api/v1/workflows/$($response.data.id)" -Method PATCH -Headers $headers -Body $activateBody
    
    Write-Host 'Workflow ACTIVE!' -ForegroundColor Green
    Write-Host ''
    Write-Host "Test webhook: POST http://localhost:5678/webhook/cindy-telegram" -ForegroundColor Cyan
}
catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
}
