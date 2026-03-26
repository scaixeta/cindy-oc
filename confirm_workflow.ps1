#!/usr/bin/env pwsh
# Confirmar workflows publicados

# Carregar variáveis de ambiente
Get-Content ".scr/.env" | Where-Object { $_ -match "^N8N_" } | ForEach-Object {
    $key, $value = $_ -split "=", 2
    [Environment]::SetEnvironmentVariable($key, $value)
}

$API_KEY = [Environment]::GetEnvironmentVariable("N8N_API_KEY")
$N8N_URL = [Environment]::GetEnvironmentVariable("N8N_URL")

if (-not $API_KEY -or -not $N8N_URL) {
    Write-Host "✗ Erro: Variáveis de ambiente não encontradas"
    exit 1
}

Write-Host "================================"
Write-Host "Confirmar Workflows Publicados"
Write-Host "================================"

try {
    $headers = @{
        "X-N8N-API-KEY" = $API_KEY
        "Content-Type" = "application/json"
    }
    
    $response = Invoke-WebRequest -Uri "$N8N_URL/api/v1/workflows" `
        -Headers $headers `
        -UseBasicParsing `
        -ErrorAction Stop
    
    $data = $response.Content | ConvertFrom-Json
    
    if ($data.data.Count -gt 0) {
        Write-Host "`n✓ Workflows encontrados:"
        Write-Host ""
        $data.data | ForEach-Object {
            $status = if ($_.active) { "✓ ATIVO" } else { "✗ INATIVO" }
            Write-Host "  Nome: $($_.name)"
            Write-Host "  ID: $($_.id)"
            Write-Host "  Status: $status"
            Write-Host ""
        }
    }
    else {
        Write-Host "`n✗ Nenhum workflow encontrado"
    }
}
catch {
    Write-Host "`n✗ Erro ao listar workflows:"
    Write-Host "  $_"
    exit 1
}

Write-Host "================================"
