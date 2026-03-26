---
name: n8n-workflow-deployment
description: Automated workflow deployment via n8n API. Use when deploying workflows programmatically, automating activation, testing webhooks, handling credentials securely, or managing workflow lifecycle via PowerShell/REST APIs.
---

# n8n Workflow Deployment

Automated deployment and management of n8n workflows using secure API patterns and PowerShell automation.

**Validated**: March 2026 - Sprint S2 production deployment (Cindy-Telegram workflow)

---

## Overview

Workflow deployment is the bridge between local development and production. This skill covers:

1. **Creating workflows** via REST API (POST)
2. **Activating workflows** via REST API (PATCH)
3. **Testing webhooks** after deployment
4. **Managing credentials securely** (no hardcoding)
5. **Automating deployment** with PowerShell scripts

---

## Core Concepts

### 1. API-First Deployment

N8N workflows can be deployed **programmatically** instead of manually in the UI:

```
UI (Canvas)          API (Automated)
│                    │
└─ Save             └─ POST /api/v1/workflows
└─ Export           └─ PATCH /api/v1/workflows/{id}
└─ Activate         └─ GET /api/v1/workflows/{id}
                    └─ Test webhook
```

**Benefits**:
- Consistent deployment process
- Version control friendly
- CI/CD integration ready
- Repeatable and auditable

### 2. Workflow Lifecycle (API)

```
1. Create (POST)
   ├─ Send JSON to POST /api/v1/workflows
   ├─ Receive: workflow ID, status=inactive
   └─ Store ID for next steps

2. Activate (PATCH)
   ├─ Send active: true to PATCH /api/v1/workflows/{ID}
   ├─ Webhook becomes publicly available
   └─ Status: active

3. Test (POST to webhook)
   ├─ Send test payload to /webhook/path
   ├─ Verify response
   └─ Check execution history

4. Monitor
   ├─ GET /api/v1/workflows/{ID}/executions
   ├─ Monitor execution status
   └─ Handle errors
```

### 3. Credential Security Pattern

**❌ Never hardcode**:
```json
{
  "url": "https://api.telegram.org",
  "token": "123456:ABCdefGHIjkl"  // WRONG!
}
```

**✅ Use environment variables**:
```powershell
# Load from .scr/.env (not versioned)
$API_KEY = [System.Environment]::GetEnvironmentVariable("N8N_API_KEY")
$TELEGRAM_TOKEN = [System.Environment]::GetEnvironmentVariable("TELEGRAM_BOT_TOKEN")

# Inject into workflow JSON
$json.nodes | ForEach-Object {
  if ($_.parameters.token) {
    $_.parameters.token = "{{`$env.TELEGRAM_BOT_TOKEN}}"
  }
}
```

---

## Deployment Methods

### Method 1: Direct API (REST)

**Setup**:
```powershell
$API_KEY = "your-api-key"  # From N8N_API_KEY env var
$N8N_URL = "http://127.0.0.1:5678"  # N8N instance URL
$headers = @{
  "X-N8N-API-KEY" = $API_KEY
  "Content-Type" = "application/json"
}
```

**Create Workflow**:
```powershell
$workflowJson = Get-Content "workflow.json" -Raw
$response = Invoke-WebRequest -Uri "$N8N_URL/api/v1/workflows" `
  -Method POST `
  -Headers $headers `
  -Body $workflowJson `
  -UseBasicParsing

$workflowId = ($response.Content | ConvertFrom-Json).data.id
Write-Host "Workflow created: $workflowId"
```

**Activate Workflow**:
```powershell
$activateBody = @{ active = $true } | ConvertTo-Json
$response = Invoke-WebRequest -Uri "$N8N_URL/api/v1/workflows/$workflowId" `
  -Method PATCH `
  -Headers $headers `
  -Body $activateBody `
  -UseBasicParsing

Write-Host "Workflow activated"
```

**Test Webhook**:
```powershell
$testPayload = @{ text = "Test message" } | ConvertTo-Json
$response = Invoke-WebRequest -Uri "$N8N_URL/webhook/your-path" `
  -Method POST `
  -Body $testPayload `
  -ContentType "application/json" `
  -UseBasicParsing

Write-Host "Status: $($response.StatusCode)"
Write-Host "Response: $($response.Content)"
```

### Method 2: PowerShell Script (Reusable)

**Script Template** (`deploy_workflow_secure.ps1`):

```powershell
#!/usr/bin/env pwsh
# Deployment with credential management

# Load credentials from .scr/.env (not versioned)
if (-not (Test-Path ".scr/.env")) {
    Write-Host "✗ Missing .scr/.env with N8N credentials"
    exit 1
}

# Parse .env file
Get-Content ".scr/.env" | Where-Object { $_ -match "^N8N_" } | ForEach-Object {
    $key, $value = $_ -split "=", 2
    [System.Environment]::SetEnvironmentVariable($key, $value)
}

$API_KEY = [System.Environment]::GetEnvironmentVariable("N8N_API_KEY")
$N8N_URL = [System.Environment]::GetEnvironmentVariable("N8N_URL")

if (-not $API_KEY -or -not $N8N_URL) {
    Write-Host "✗ N8N_API_KEY or N8N_URL not found in .scr/.env"
    exit 1
}

Write-Host "Deploying to n8n..."

# 1. Read workflow JSON
try {
    $workflowJson = Get-Content "workflow.json" -Raw -ErrorAction Stop
} catch {
    Write-Host "✗ Error reading workflow: $_"
    exit 1
}

# 2. Clean JSON (remove read-only fields)
$workflow = $workflowJson | ConvertFrom-Json
$workflow.PSObject.Properties | 
    Where-Object { $_.Name -in @("active", "id", "versionId", "meta") } |
    ForEach-Object { $workflow.PSObject.Properties.Remove($_.Name) }
$workflowJson = $workflow | ConvertTo-Json -Depth 10

# 3. Create workflow
try {
    $headers = @{
        "X-N8N-API-KEY" = $API_KEY
        "Content-Type" = "application/json"
    }
    
    $response = Invoke-WebRequest -Uri "$N8N_URL/api/v1/workflows" `
        -Method POST `
        -Headers $headers `
        -Body $workflowJson `
        -UseBasicParsing -ErrorAction Stop
    
    $data = $response.Content | ConvertFrom-Json
    $workflowId = $data.data.id
    
    Write-Host "✓ Workflow created: $workflowId"
} catch {
    Write-Host "✗ Error creating workflow: $_"
    exit 1
}

# 4. Activate workflow
try {
    $activateBody = @{ active = $true } | ConvertTo-Json
    
    Invoke-WebRequest -Uri "$N8N_URL/api/v1/workflows/$workflowId" `
        -Method PATCH `
        -Headers $headers `
        -Body $activateBody `
        -UseBasicParsing -ErrorAction Stop
    
    Write-Host "✓ Workflow activated"
} catch {
    Write-Host "⚠ Error activating: $_"
}

# 5. Test webhook
try {
    $testPayload = @{ test = "data" } | ConvertTo-Json
    
    $webhookResponse = Invoke-WebRequest -Uri "$N8N_URL/webhook/your-path" `
        -Method POST `
        -Body $testPayload `
        -ContentType "application/json" `
        -UseBasicParsing -ErrorAction Stop
    
    Write-Host "✓ Webhook functional: Status $($webhookResponse.StatusCode)"
} catch {
    Write-Host "⚠ Webhook test: $_"
}

Write-Host "✓ Deployment complete"
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

### Phase 1: Preparation

**1.1 Extract Workflow JSON**

From UI:
```
1. Open workflow editor
2. Click menu (⋯)
3. Select "Export" or "Download"
4. Save as workflow.json
```

From API:
```powershell
$response = Invoke-WebRequest -Uri "$N8N_URL/api/v1/workflows/$ID" `
  -Headers @{"X-N8N-API-KEY" = $API_KEY} -UseBasicParsing
$response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 10 > workflow.json
```

**1.2 Validate JSON**

```powershell
# Test JSON is valid
$json = Get-Content workflow.json | ConvertFrom-Json
Write-Host "✓ Valid JSON"
```

**1.3 Identify Credentials**

Find all hardcoded values:
```powershell
$json = Get-Content workflow.json | ConvertFrom-Json
$json | ConvertTo-Json -Depth 20 | Select-String -Pattern "sk-|Bearer|password|token" |
  ForEach-Object { Write-Host "Found: $_" }
```

### Phase 2: Secure Preparation

**2.1 Extract Credentials**

Replace hardcoded values with env references:

**Before**:
```json
{
  "parameters": {
    "token": "123456:ABCdefGHI"
  }
}
```

**After**:
```json
{
  "parameters": {
    "token": "{{$env.TELEGRAM_BOT_TOKEN}}"
  }
}
```

**2.2 Remove Read-Only Fields**

```powershell
$json = Get-Content workflow.json | ConvertFrom-Json

# Remove fields that are read-only
@("active", "id", "versionId", "meta", "pinData") | ForEach-Object {
    $json.PSObject.Properties.Remove($_)
}

$json | ConvertTo-Json -Depth 10 | Set-Content workflow_clean.json
```

**2.3 Store Credentials in .scr/.env**

```bash
# .scr/.env (NOT versioned)
N8N_API_KEY=your-api-key-here
N8N_URL=http://127.0.0.1:5678
TELEGRAM_BOT_TOKEN=123456:ABCdefGHIjkl
MINIMAX_API_KEY=sk-abc123xyz
```

Add to `.gitignore`:
```
.scr/
.env
*.env
```

### Phase 3: Deployment

**3.1 Create Workflow**

```powershell
$headers = @{
  "X-N8N-API-KEY" = $env:N8N_API_KEY
  "Content-Type" = "application/json"
}

$json = Get-Content workflow_clean.json -Raw

$response = Invoke-WebRequest -Uri "$env:N8N_URL/api/v1/workflows" `
  -Method POST -Headers $headers -Body $json -UseBasicParsing

$workflowId = ($response.Content | ConvertFrom-Json).data.id
Write-Host "Created: $workflowId"
```

**3.2 Activate Workflow**

```powershell
$activateBody = @{ active = $true } | ConvertTo-Json

Invoke-WebRequest -Uri "$env:N8N_URL/api/v1/workflows/$workflowId" `
  -Method PATCH -Headers $headers -Body $activateBody -UseBasicParsing

Write-Host "Activated: $workflowId"
```

**3.3 Verify Webhook**

```powershell
$test = Invoke-WebRequest -Uri "$env:N8N_URL/webhook/your-path" `
  -Method POST -Body '{"test":"data"}' -ContentType "application/json" `
  -UseBasicParsing

Write-Host "Status: $($test.StatusCode)"
```

### Phase 4: Validation

**4.1 Check Activation**

```powershell
$response = Invoke-WebRequest -Uri "$env:N8N_URL/api/v1/workflows/$workflowId" `
  -Headers @{"X-N8N-API-KEY" = $env:N8N_API_KEY} -UseBasicParsing

$json = $response.Content | ConvertFrom-Json
Write-Host "Active: $($json.data.active)"
```

**4.2 Monitor Executions**

```powershell
$executions = Invoke-WebRequest -Uri "$env:N8N_URL/api/v1/workflows/$workflowId/executions" `
  -Headers @{"X-N8N-API-KEY" = $env:N8N_API_KEY} -UseBasicParsing

$json = $response.Content | ConvertFrom-Json
$json.data | ForEach-Object {
  Write-Host "$($_.id): $($_.status) at $($_.startedAt)"
}
```

**4.3 View Logs**

In N8N UI:
```
1. Open workflow
2. Click "Executions"
3. View execution history
4. Click execution to see details
```

---

## Common Deployment Patterns

### Pattern 1: Deploy & Activate

```powershell
# Create
$response = Invoke-WebRequest -Uri "$url/api/v1/workflows" -Method POST ...
$id = ($response.Content | ConvertFrom-Json).data.id

# Activate
Invoke-WebRequest -Uri "$url/api/v1/workflows/$id" -Method PATCH -Body '{"active":true}'

# Done
Write-Host "Deployed and active: $id"
```

### Pattern 2: Deploy, Test, Notify

```powershell
# Create
$response = Invoke-WebRequest -Uri "$url/api/v1/workflows" -Method POST ...
$id = ($response.Content | ConvertFrom-Json).data.id

# Activate
Invoke-WebRequest -Uri "$url/api/v1/workflows/$id" -Method PATCH -Body '{"active":true}'

# Test
$test = Invoke-WebRequest -Uri "$url/webhook/path" -Method POST -Body $payload

# Notify
if ($test.StatusCode -eq 200) {
    Send-SlackNotification "✓ Workflow $id deployed successfully"
} else {
    Send-SlackNotification "✗ Deployment failed: $($test.StatusCode)"
}
```

### Pattern 3: Deploy with Rollback

```powershell
# Get current active ID
$current = Invoke-WebRequest -Uri "$url/api/v1/workflows?filter=active" ...
$currentId = ($current.Content | ConvertFrom-Json).data[0].id

# Deploy new
$new = Invoke-WebRequest -Uri "$url/api/v1/workflows" -Method POST ...
$newId = ($new.Content | ConvertFrom-Json).data.id

# Test new
$test = Invoke-WebRequest -Uri "$url/webhook/path" -Method POST -Body $payload

if ($test.StatusCode -ne 200) {
    # Rollback
    Invoke-WebRequest -Uri "$url/api/v1/workflows/$currentId" -Method PATCH -Body '{"active":true}'
    Write-Host "Rolled back to $currentId"
    exit 1
}

# Deactivate old, activate new
Invoke-WebRequest -Uri "$url/api/v1/workflows/$currentId" -Method PATCH -Body '{"active":false}'
Invoke-WebRequest -Uri "$url/api/v1/workflows/$newId" -Method PATCH -Body '{"active":true}'
Write-Host "Switched from $currentId to $newId"
```

---

## Error Handling

### Common Errors & Solutions

| Error | Cause | Solution |
|-------|-------|----------|
| `404 webhook not registered` | Workflow not activated | PATCH with `active: true` |
| `active is read-only` | Sending active in POST | Remove from JSON before POST, add in PATCH |
| `Unauthorized (401)` | Wrong API key | Check `N8N_API_KEY` in `.scr/.env` |
| `Invalid JSON` | Malformed JSON | Validate with `ConvertFrom-Json -ErrorAction Stop` |
| `Connection refused` | N8N not running | Start N8N: `docker-compose up` |
| `PATCH not allowed` | Wrong HTTP method | Use PATCH for activation (not PUT/POST) |

### Debugging Workflow JSON

```powershell
# Validate JSON syntax
try {
    $json = Get-Content workflow.json | ConvertFrom-Json
    Write-Host "✓ Valid JSON"
} catch {
    Write-Host "✗ JSON Error: $_"
}

# Check for hardcoded credentials
$content = Get-Content workflow.json
$content | Select-String -Pattern "sk-|Bearer|password|token" |
    ForEach-Object { Write-Host "⚠ Found credential: $_" }

# Verify structure
$json = Get-Content workflow.json | ConvertFrom-Json
Write-Host "Nodes: $($json.nodes.Count)"
Write-Host "Connections: $($json.connections.Keys.Count)"
Write-Host "Settings: $($json.settings.executionOrder)"
```

---

## Security Checklist

- [ ] No credentials in JSON (use `{{$env.VAR_NAME}}`)
- [ ] `.scr/.env` exists with all credentials
- [ ] `.gitignore` includes `.scr/`, `*.env`
- [ ] API key stored in environment variable
- [ ] Webhook path is appropriate (not `/webhook`)
- [ ] HTTPS enforced for production
- [ ] API key rotated after testing
- [ ] Execution logs don't expose secrets

---

## Integration with Other Skills

**n8n-workflow-patterns** - Use to:
- Understand workflow structure
- Plan deployment strategy
- Design data flow

**n8n-node-configuration** - Use to:
- Configure nodes before deployment
- Understand field requirements
- Validate node parameters

**n8n-validation-expert** - Use to:
- Fix workflow validation errors
- Ensure workflow is ready for deployment
- Handle validation warnings

---

## Real Example: Cindy-Telegram Workflow

**Sprint S2 Production Deployment**:

```powershell
# 1. Prepared workflow JSON with env references
# 2. Cleaned read-only fields (active, id, versionId)
# 3. Created via POST /api/v1/workflows
# 4. Got ID: f0Nbq7BA3mPoxZvZ
# 5. Activated via PATCH with active: true
# 6. Tested webhook: curl -X POST http://127.0.0.1:5678/webhook/cindy-telegram
# 7. Verified status: ✓ 200 OK
# 8. Monitored executions in UI
# 9. All tests passing (6/6 in Sprint S2)
```

Result: **Production-ready workflow deployed and validated**

---

## Best Practices

### ✅ Do

- Always clean JSON before POST (remove active, id, versionId, meta)
- Store credentials in `.scr/.env` (not versioned)
- Use env references in workflow JSON: `{{$env.VAR_NAME}}`
- Test webhook after deployment
- Monitor executions after activation
- Version control the workflow JSON (without secrets)
- Document deployment process
- Rotate API keys after development

### ❌ Don't

- Hardcode credentials in workflow JSON
- Send `active: true` in POST request
- Deploy without testing webhook
- Skip credential management
- Use same API key for dev/prod
- Assume activation succeeds (check response)
- Share `.scr/.env` or credentials
- Deploy without validation

---

## Summary

**Deployment Workflow**:
1. Extract and validate workflow JSON
2. Remove hardcoded credentials (use env references)
3. Clean read-only fields
4. POST to create workflow (get ID)
5. PATCH to activate workflow
6. Test webhook functionality
7. Monitor executions

**Key Tools**:
- PowerShell 7.x for automation
- REST API for all operations
- `.scr/.env` for credential management
- Validation before deployment

**Related Skills**:
- n8n-workflow-patterns - Workflow design
- n8n-node-configuration - Node setup
- n8n-validation-expert - Error handling

---

**Last Updated**: March 2026 (Sprint S2)  
**Status**: Validated with production deployment
