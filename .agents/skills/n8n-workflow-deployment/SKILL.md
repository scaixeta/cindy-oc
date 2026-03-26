---
name: n8n-workflow-deployment
description: Automated workflow deployment via n8n API. Use when deploying workflows programmatically, automating activation, testing webhooks, handling credentials securely, or managing workflow lifecycle via PowerShell/REST APIs.
---

# n8n Workflow Deployment

Automated deployment and management of n8n workflows using REST API and PowerShell automation.

**Ported from**: `.cline/skills/n8n-workflow-deployment` (March 2026)
**Validated**: Production deployment of Cindy-Telegram workflow (ID: f0Nbq7BA3mPoxZvZ)

---

## Overview

Workflow deployment bridges local development and production execution through API-driven automation:

1. **Create workflows** via POST `/api/v1/workflows`
2. **Activate workflows** via PATCH `/api/v1/workflows/{id}`
3. **Test webhooks** after deployment
4. **Manage credentials** securely (no hardcoding)
5. **Automate deployments** with reusable scripts

---

## Core Deployment Concepts

### Workflow Lifecycle

```
Phase 1: Preparation (Local)
├─ Extract JSON from UI or API
├─ Validate JSON syntax
├─ Identify and externalize credentials
└─ Remove read-only fields

Phase 2: Create (API POST)
├─ Send clean JSON to POST /api/v1/workflows
├─ Receive workflow ID and metadata
└─ Store ID for activation

Phase 3: Activate (API PATCH)
├─ Send active: true to PATCH /api/v1/workflows/{ID}
├─ Webhook becomes accessible
└─ Workflow starts receiving events

Phase 4: Validate (Functional Testing)
├─ Test webhook endpoint
├─ Verify response handling
├─ Check execution history
└─ Confirm success/failure paths

Phase 5: Monitor (Ongoing)
├─ Track execution status
├─ Log errors and issues
├─ Plan rollback if needed
└─ Document lessons learned
```

### Credential Security Model

**❌ Never in JSON**:
```json
{"token": "sk-abc123xyz"}
```

**✅ Always use env references**:
```json
{"token": "{{$env.API_KEY}}"}
```

**✅ Load from `.scr/.env` (not versioned)**:
```powershell
$env:API_KEY = Get-Content ".scr/.env" | Select-String "API_KEY=" | ForEach-Object { $_.Split("=")[1] }
```

---

## Deployment Methods

### Method A: Direct REST API Calls

**Setup**:
```powershell
$API_KEY = [System.Environment]::GetEnvironmentVariable("N8N_API_KEY")
$N8N_URL = "http://127.0.0.1:5678"
$headers = @{
  "X-N8N-API-KEY" = $API_KEY
  "Content-Type" = "application/json"
}
```

**Create Workflow**:
```powershell
$json = Get-Content "workflow.json" -Raw

$response = Invoke-WebRequest -Uri "$N8N_URL/api/v1/workflows" `
  -Method POST -Headers $headers -Body $json -UseBasicParsing

$id = ($response.Content | ConvertFrom-Json).data.id
Write-Host "✓ Created: $id"
```

**Activate Workflow**:
```powershell
$activate = @{ active = $true } | ConvertTo-Json

Invoke-WebRequest -Uri "$N8N_URL/api/v1/workflows/$id" `
  -Method PATCH -Headers $headers -Body $activate -UseBasicParsing

Write-Host "✓ Activated: $id"
```

**Test Webhook**:
```powershell
$payload = @{ test = "data" } | ConvertTo-Json

$test = Invoke-WebRequest -Uri "$N8N_URL/webhook/path" `
  -Method POST -Body $payload -ContentType "application/json" -UseBasicParsing

Write-Host "✓ Status: $($test.StatusCode)"
```

### Method B: Automated PowerShell Script

**Full Example** (`deploy_workflow_secure.ps1`):

```powershell
#!/usr/bin/env pwsh

# 1. Load credentials from .scr/.env
if (-not (Test-Path ".scr/.env")) {
    Write-Host "✗ Missing .scr/.env"
    exit 1
}

Get-Content ".scr/.env" | Where-Object { $_ -match "^N8N_" } | ForEach-Object {
    $key, $value = $_ -split "=", 2
    [System.Environment]::SetEnvironmentVariable($key, $value)
}

$API_KEY = [System.Environment]::GetEnvironmentVariable("N8N_API_KEY")
$N8N_URL = [System.Environment]::GetEnvironmentVariable("N8N_URL")

if (-not $API_KEY -or -not $N8N_URL) {
    Write-Host "✗ Env vars missing"
    exit 1
}

# 2. Read and clean JSON
$json = Get-Content "workflow.json" -Raw | ConvertFrom-Json
@("active", "id", "versionId", "meta", "pinData") | ForEach-Object {
    $json.PSObject.Properties.Remove($_)
}
$json = $json | ConvertTo-Json -Depth 10

# 3. Deploy
$headers = @{
    "X-N8N-API-KEY" = $API_KEY
    "Content-Type" = "application/json"
}

try {
    $resp = Invoke-WebRequest -Uri "$N8N_URL/api/v1/workflows" `
        -Method POST -Headers $headers -Body $json -UseBasicParsing -ErrorAction Stop
    
    $id = ($resp.Content | ConvertFrom-Json).data.id
    Write-Host "✓ Created: $id"
} catch {
    Write-Host "✗ Error: $_"
    exit 1
}

# 4. Activate
try {
    Invoke-WebRequest -Uri "$N8N_URL/api/v1/workflows/$id" `
        -Method PATCH -Headers $headers `
        -Body (@{active = $true} | ConvertTo-Json) -UseBasicParsing -ErrorAction Stop
    
    Write-Host "✓ Activated: $id"
} catch {
    Write-Host "⚠ Activation failed: $_"
}

# 5. Test
try {
    $test = Invoke-WebRequest -Uri "$N8N_URL/webhook/your-path" `
        -Method POST -Body '{"test":"data"}' `
        -ContentType "application/json" -UseBasicParsing -ErrorAction Stop
    
    Write-Host "✓ Webhook OK: Status $($test.StatusCode)"
} catch {
    Write-Host "⚠ Webhook test: $_"
}

Write-Host "`n✓ Deployment Complete"
```

**Usage**:
```powershell
# Ensure .scr/.env exists with:
# N8N_API_KEY=your-key
# N8N_URL=http://127.0.0.1:5678

pwsh -ExecutionPolicy Bypass -File deploy_workflow_secure.ps1
```

---

## Step-by-Step Deployment Guide

### Step 1: Preparation

**Extract JSON**:
```powershell
# From UI: Export → Save as workflow.json
# From API:
$resp = Invoke-WebRequest -Uri "$N8N_URL/api/v1/workflows/$ID" `
  -Headers @{"X-N8N-API-KEY" = $API_KEY} -UseBasicParsing
$resp.Content | ConvertFrom-Json | ConvertTo-Json -Depth 10 > workflow.json
```

**Validate JSON**:
```powershell
try {
    $json = Get-Content workflow.json | ConvertFrom-Json
    Write-Host "✓ Valid JSON"
} catch {
    Write-Host "✗ JSON Error: $_"
}
```

**Find Credentials**:
```powershell
$content = Get-Content workflow.json
$content | Select-String -Pattern "sk-|Bearer|token|password" |
  ForEach-Object { Write-Host "⚠ Found: $_" }
```

### Step 2: Secure Preparation

**Replace Hardcoded Values**:
```powershell
# Before: "token": "sk-abc123"
# After:  "token": "{{$env.API_KEY}}"

$json = Get-Content workflow.json | ConvertFrom-Json
$json.nodes | ForEach-Object {
    if ($_.parameters.token) {
        $_.parameters.token = "{{`$env.TOKEN_ENV_VAR}}"
    }
}
$json | ConvertTo-Json -Depth 10 | Set-Content workflow_clean.json
```

**Store Credentials**:
```bash
# .scr/.env (NOT versioned, add to .gitignore)
N8N_API_KEY=your-api-key
N8N_URL=http://127.0.0.1:5678
TELEGRAM_BOT_TOKEN=123456:ABCxyz
API_KEY=sk-abc123
```

**Clean Read-Only Fields**:
```powershell
$json = Get-Content workflow_clean.json | ConvertFrom-Json
@("active", "id", "versionId", "meta", "pinData") | ForEach-Object {
    $json.PSObject.Properties.Remove($_)
}
$json | ConvertTo-Json -Depth 10 | Set-Content workflow_deploy.json
```

### Step 3: Deploy via API

**Create Workflow**:
```powershell
$json = Get-Content workflow_deploy.json -Raw
$headers = @{
    "X-N8N-API-KEY" = $env:N8N_API_KEY
    "Content-Type" = "application/json"
}

$resp = Invoke-WebRequest -Uri "$env:N8N_URL/api/v1/workflows" `
  -Method POST -Headers $headers -Body $json -UseBasicParsing

$id = ($resp.Content | ConvertFrom-Json).data.id
Write-Host "✓ Created: $id"
```

**Activate Workflow**:
```powershell
$activate = @{ active = $true } | ConvertTo-Json

Invoke-WebRequest -Uri "$env:N8N_URL/api/v1/workflows/$id" `
  -Method PATCH -Headers $headers -Body $activate -UseBasicParsing

Write-Host "✓ Activated: $id"
```

### Step 4: Verify

**Check Activation Status**:
```powershell
$resp = Invoke-WebRequest -Uri "$env:N8N_URL/api/v1/workflows/$id" `
  -Headers @{"X-N8N-API-KEY" = $env:N8N_API_KEY} -UseBasicParsing

$data = $resp.Content | ConvertFrom-Json
Write-Host "Active: $($data.data.active)"
```

**Test Webhook**:
```powershell
$test = Invoke-WebRequest -Uri "$env:N8N_URL/webhook/your-path" `
  -Method POST -Body '{"test":"data"}' -ContentType "application/json" -UseBasicParsing

Write-Host "Status: $($test.StatusCode)"
Write-Host "Response: $($test.Content)"
```

**Monitor Executions**:
```powershell
$execs = Invoke-WebRequest -Uri "$env:N8N_URL/api/v1/workflows/$id/executions" `
  -Headers @{"X-N8N-API-KEY" = $env:N8N_API_KEY} -UseBasicParsing

($execs.Content | ConvertFrom-Json).data | ForEach-Object {
    Write-Host "$($_.id): $($_.status)"
}
```

---

## Common Deployment Patterns

### Pattern 1: Deploy & Activate

```powershell
# Single script to deploy and activate
$resp = Invoke-WebRequest -Uri "$url/api/v1/workflows" -Method POST ...
$id = ($resp.Content | ConvertFrom-Json).data.id
Invoke-WebRequest -Uri "$url/api/v1/workflows/$id" -Method PATCH -Body '{"active":true}'
Write-Host "✓ Ready: $id"
```

### Pattern 2: Deploy, Test, Alert

```powershell
$resp = Invoke-WebRequest -Uri "$url/api/v1/workflows" -Method POST ...
$id = ($resp.Content | ConvertFrom-Json).data.id

Invoke-WebRequest -Uri "$url/api/v1/workflows/$id" -Method PATCH -Body '{"active":true}'

$test = Invoke-WebRequest -Uri "$url/webhook/path" -Method POST -Body $payload

if ($test.StatusCode -eq 200) {
    Write-Host "✓ Success: $id"
} else {
    Write-Host "✗ Failed"
    # Send alert
}
```

### Pattern 3: Canary Deployment

```powershell
# Deploy new version alongside old
$new = Invoke-WebRequest -Uri "$url/api/v1/workflows" -Method POST ...
$newId = ($new.Content | ConvertFrom-Json).data.id

# Test new version
$test = Invoke-WebRequest -Uri "$url/webhook/canary" -Method POST -Body $payload

if ($test.StatusCode -eq 200) {
    # Switch traffic
    Invoke-WebRequest -Uri "$url/api/v1/workflows/$oldId" -Method PATCH -Body '{"active":false}'
    Invoke-WebRequest -Uri "$url/api/v1/workflows/$newId" -Method PATCH -Body '{"active":true}'
}
```

---

## Error Handling

### Common Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `404 webhook not registered` | Not activated | PATCH with `active: true` |
| `active is read-only` | Sent in POST body | Remove before POST, add in PATCH |
| `401 Unauthorized` | Invalid API key | Check `N8N_API_KEY` env var |
| `Invalid JSON` | Malformed JSON | Validate with `ConvertFrom-Json` |
| `Connection refused` | N8N not running | Start with `docker-compose up` |
| `PATCH not allowed` | Wrong method | Use PATCH, not PUT or POST |

### Debugging

```powershell
# Validate JSON
try {
    $json = Get-Content workflow.json | ConvertFrom-Json
    Write-Host "✓ Valid"
} catch {
    Write-Host "✗ Error: $_"
}

# Find credentials in JSON
$content = Get-Content workflow.json
$content | Select-String -Pattern "sk-|Bearer|token" |
    ForEach-Object { Write-Host "⚠ Found: $_" }

# Verify structure
$json = Get-Content workflow.json | ConvertFrom-Json
Write-Host "Nodes: $($json.nodes.Count)"
Write-Host "Connections: $($json.connections.Keys.Count)"
```

---

## Security Checklist

- [ ] No credentials in JSON (use `{{$env.VAR}}`)
- [ ] `.scr/.env` has all credentials
- [ ] `.gitignore` includes `.scr/`, `*.env`
- [ ] API key in environment variable
- [ ] Webhook path is meaningful (not `/webhook`)
- [ ] HTTPS for production
- [ ] API key rotated after dev
- [ ] No secrets in execution logs

---

## Real Example: Cindy-Telegram

**Sprint S2 Production Deployment**:

```powershell
# Step 1: Extracted JSON from UI
# Step 2: Identified credentials: TELEGRAM_BOT_TOKEN
# Step 3: Cleaned read-only fields (active, id, versionId)
# Step 4: Created via POST → ID: f0Nbq7BA3mPoxZvZ
# Step 5: Activated via PATCH → active: true
# Step 6: Tested webhook → Status 200 OK
# Step 7: Verified in UI → Executions flowing
# Result: ✓ Production-ready workflow
```

---

## Best Practices

### ✅ Do
- Clean JSON before POST (remove active, id, versionId, meta)
- Store credentials in `.scr/.env` (not versioned)
- Use env references: `{{$env.VAR_NAME}}`
- Test webhook after deployment
- Monitor executions after activation
- Version control workflow JSON (without secrets)
- Document deployment process
- Rotate API keys after development

### ❌ Don't
- Hardcode credentials in JSON
- Send `active: true` in POST
- Deploy without testing
- Skip credential management
- Use same key for dev/prod
- Assume activation succeeds
- Share `.scr/.env`
- Deploy without validation

---

## Integration with Other Skills

**n8n-workflow-patterns** - Use to:
- Understand workflow structure
- Plan deployment strategy

**n8n-node-configuration** - Use to:
- Configure nodes before deployment
- Validate node parameters

**n8n-validation-expert** - Use to:
- Fix validation errors
- Ensure readiness

---

## Summary

**Deployment Steps**:
1. Extract and validate JSON
2. Externalize credentials
3. Clean read-only fields
4. POST to create (get ID)
5. PATCH to activate
6. Test webhook
7. Monitor executions

**Key Tools**: PowerShell 7.x, REST API, `.scr/.env`

---

**Last Updated**: March 2026 (Sprint S2)  
**Status**: Production-validated
