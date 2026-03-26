#!/usr/bin/env pwsh
# Deploy secure workflow to n8n
# Credenciais carregadas de .scr/.env (não versionar)

if (-not (Test-Path ".scr/.env")) {
    Write-Host "✗ Erro: Arquivo .scr/.env não encontrado"
    exit 1
}

# Carregar variáveis de ambiente
Get-Content ".scr/.env" | Where-Object { $_ -match "^N8N_" } | ForEach-Object {
    $key, $value = $_ -split "=", 2
    [System.Environment]::SetEnvironmentVariable($key, $value)
}

$API_KEY = [System.Environment]::GetEnvironmentVariable("N8N_API_KEY")
$N8N_URL = [System.Environment]::GetEnvironmentVariable("N8N_URL")

if (-not $API_KEY -or -not $N8N_URL) {
    Write-Host "✗ Erro: N8N_API_KEY ou N8N_URL não encontrados em .scr/.env"
    exit 1
}

Write-Host "================================"
Write-Host "Deploy Workflow to n8n (Seguro)"
Write-Host "================================"

# Read workflow from file
Write-Host "`n[1] Lendo workflow..."
try {
    $workflowJson = Get-Content -Path "workflow_simple.json" -Raw -ErrorAction Stop
    Write-Host "✓ Arquivo lido com sucesso"
}
catch {
    Write-Host "✗ Erro ao ler arquivo: $_"
    exit 1
}

# Deploy workflow
Write-Host "`n[2] Enviando workflow para n8n..."
try {
    $headers = @{
        "X-N8N-API-KEY" = $API_KEY
        "Content-Type" = "application/json"
    }
    
    $response = Invoke-WebRequest -Uri "$N8N_URL/api/v1/workflows" `
        -Method POST `
        -Headers $headers `
        -Body $workflowJson `
        -UseBasicParsing `
        -ErrorAction Stop
    
    $data = $response.Content | ConvertFrom-Json
    $workflowId = $data.data.id
    
    Write-Host "✓ Workflow criado com sucesso!"
    Write-Host "  ID: $workflowId"
    Write-Host "  Nome: $($data.data.name)"
}
catch {
    Write-Host "✗ Erro ao criar workflow:"
    Write-Host "  $_"
    exit 1
}

# Activate workflow
Write-Host "`n[2b] Ativando workflow..."
try {
    $activateBody = @{
        active = $true
    } | ConvertTo-Json
    
    $activateResponse = Invoke-WebRequest -Uri "$N8N_URL/api/v1/workflows/$workflowId" `
        -Method PATCH `
        -Headers $headers `
        -Body $activateBody `
        -UseBasicParsing `
        -ErrorAction Stop
    
    Write-Host "✓ Workflow ativado!"
}
catch {
    Write-Host "⚠ Erro ao ativar: $_"
}

# Test webhook
Write-Host "`n[3] Testando webhook..."
try {
    $testPayload = @{
        text = "Test from Cindy"
    } | ConvertTo-Json
    
    $webhookResponse = Invoke-WebRequest -Uri "$N8N_URL/webhook/cindy-telegram" `
        -Method POST `
        -Body $testPayload `
        -ContentType "application/json" `
        -UseBasicParsing `
        -ErrorAction Stop
    
    Write-Host "✓ Webhook funcional!"
    Write-Host "  Status: $($webhookResponse.StatusCode)"
}
catch {
    Write-Host "⚠ Webhook test: $_"
}

Write-Host "`n================================"
Write-Host "✓ WORKFLOW DEPLOYED SECURELY"
Write-Host "================================"
