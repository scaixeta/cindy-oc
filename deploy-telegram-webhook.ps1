# Deploy Cindy-Telegram-n8n webhook workflow
# Usage: pwsh -ExecutionPolicy Bypass -File deploy-telegram-webhook.ps1

$env:PSModulePath = $env:PSModulePath -replace '\\Modules', ';C:\WINDOWS\System32\WindowsPowerShell\v1.0\Modules'

$N8N_URL = 'http://127.0.0.1:5678'
$API_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI2YTYzNGNkMC0zYTY4LTQ4NWUtOWEyZS05MWYxODEwNTc1YWQiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwianRpIjoiMWVjODJjZDEtZDU0My00Y2U1LTljYzktMGE0ZTFlNDA2NjUzIiwiaWF0IjoxNzc0NTU0MDQwfQ.1-mM231NLR09FPT9DWOtQ6YkgE0NUPxbul73J51oOio'

Write-Host '=== Deploying Cindy-Telegram-n8n ===' -ForegroundColor Cyan

# Load workflow
$workflowPath = 'C:\Cindy-OC\workflow-cindy-telegram.json'
$workflow = Get-Content $workflowPath -Raw | ConvertFrom-Json

Write-Host "Name: $($workflow.name)"
Write-Host "Path: cindy-telegram"

# Headers
$headers = @{
    'X-N8N-API-KEY' = $API_KEY
    'Content-Type' = 'application/json'
}

# Deploy
try {
    Write-Host 'Creating workflow...' -ForegroundColor Yellow
    $response = Invoke-RestMethod -Uri "$N8N_URL/api/v1/workflows" -Method POST -Headers $headers -Body ($workflow | ConvertTo-Json -Depth 10)
    
    $workflowId = $response.data.id
    Write-Host "SUCCESS! Workflow ID: $workflowId" -ForegroundColor Green
    
    # Activate
    Write-Host 'Activating workflow...' -ForegroundColor Yellow
    $activateBody = @{ active = $true } | ConvertTo-Json
    $activateResponse = Invoke-RestMethod -Uri "$N8N_URL/api/v1/workflows/$workflowId" -Method PATCH -Headers $headers -Body $activateBody
    
    Write-Host 'Workflow ACTIVE!' -ForegroundColor Green
    Write-Host ''
    Write-Host "Webhook URL: POST http://127.0.0.1:5678/webhook/cindy-telegram" -ForegroundColor Cyan
}
catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
}
