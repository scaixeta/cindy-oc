---
name: n8n-workflow-deployment
description: Automated workflow deployment via n8n API. Use when deploying workflows programmatically, automating activation, testing webhooks, handling credentials securely, or managing workflow lifecycle via PowerShell/REST APIs.
---

# n8n Workflow Deployment

Automated deployment and management of n8n workflows using REST API and PowerShell.

**Ported to**: `.codex/skills/n8n-workflow-deployment` (March 2026)
**Reference**: Sprint S2 Cindy-Telegram workflow deployment (ID: f0Nbq7BA3mPoxZvZ)
**Status**: Production-validated

---

## Deployment Lifecycle

```
Phase 1: Preparation
├─ Extract JSON from UI or API
├─ Validate JSON syntax
├─ Identify and externalize credentials
└─ Remove read-only fields (active, id, versionId, meta)

Phase 2: Create (POST)
├─ Send clean JSON to POST /api/v1/workflows
├─ Receive workflow ID
└─ Store ID for activation

Phase 3: Activate (PATCH)
├─ Send active: true to PATCH /api/v1/workflows/{ID}
├─ Webhook becomes accessible
└─ Workflow ready for events

Phase 4: Validate
├─ Test webhook endpoint
├─ Verify response handling
├─ Check execution history
└─ Confirm success paths

Phase 5: Monitor
├─ Track executions
├─ Log errors
└─ Document lessons learned
```

---

## Credential Security Model

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
Get-Content ".scr/.env" | Where-Object { $_ -match "^N8N_" } | ForEach-Object {
    $key, $value = $_ -split "=", 2
    [System.Environment]::SetEnvironmentVariable($key, $value)
}
```

---

## REST API Deployment

### Setup
```powershell
$API_KEY = [System.Environment]::GetEnvironmentVariable("N8N_API_KEY")
$N8N_URL = "http://127.0.0.1:5678"
$headers = @{
  "X-N8N-API-KEY" = $API_KEY
  "Content-Type" = "application/json"
}
```

### Create Workflow
```powershell
$json = Get-Content "workflow.json" -Raw

$response = Invoke-WebRequest -Uri "$N8N_URL/api/v1/workflows" `
  -Method POST -Headers $headers -Body $json -UseBasicParsing

$id = ($response.Content | ConvertFrom-Json).data.id
Write-Host "✓ Created: $id"
```

### Activate Workflow
```powershell
$activate = @{ active = $true } | ConvertTo-Json

Invoke-WebRequest -Uri "$N8N_URL/api/v1/workflows/$id" `
  -Method PATCH -Headers $headers -Body $activate -UseBasicParsing

Write-Host "✓ Activated: $id"
```

### Test Webhook
```powershell
$payload = @{ test = "data" } | ConvertTo-Json

$test = Invoke-WebRequest -Uri "$N8N_URL/webhook/path" `
  -Method POST -Body $payload -ContentType "application/json" -UseBasicParsing

Write-Host "✓ Status: $($test.StatusCode)"
```

---

## Automated PowerShell Script

**Full deployment script** (`deploy_workflow_secure.ps1`):

```powershell
#!/usr/bin/env pwsh

# 1. Load credentials
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
    Write-Host "⚠ Activation: $_"
}

# 5. Test
try {
    $test = Invoke-WebRequest -Uri "$N8N_URL/webhook/your-path" `
        -Method POST -Body '{"test":"data"}' `
        -ContentType "application/json" -UseBasicParsing -ErrorAction Stop
    
    Write-Host "✓ Webhook OK: Status $($test.StatusCode)"
} catch {
    Write-Host "⚠ Webhook: $_"
}

Write-Host "`n✓ Done"
```

---

## Step-by-Step Guide

### Step 1: Preparation
```powershell
# Extract JSON
$resp = Invoke-WebRequest -Uri "$N8N_URL/api/v1/workflows/$ID" `
  -Headers @{"X-N8N-API-KEY" = $API_KEY} -UseBasicParsing
$resp.Content | ConvertFrom-Json | ConvertTo-Json -Depth 10 > workflow.json

# Validate
$json = Get-Content workflow.json | ConvertFrom-Json
Write-Host "✓ Valid JSON"

# Find credentials
$content = Get-Content workflow.json
$content | Select-String -Pattern "sk-|Bearer|token" |
  ForEach-Object { Write-Host "⚠ Found: $_" }
```

### Step 2: Secure Preparation
```powershell
# Replace credentials
$json.nodes | ForEach-Object {
    if ($_.parameters.token) {
        $_.parameters.token = "{{`$env.TOKEN_VAR}}"
    }
}

# Clean read-only fields
@("active", "id", "versionId", "meta", "pinData") | ForEach-Object {
    $json.PSObject.Properties.Remove($_)
}

$json | ConvertTo-Json -Depth 10 | Set-Content workflow_deploy.json
```

### Step 3: Deploy
```powershell
$json = Get-Content workflow_deploy.json -Raw
$headers = @{
    "X-N8N-API-KEY" = $env:N8N_API_KEY
    "Content-Type" = "application/json"
}

# Create
$resp = Invoke-WebRequest -Uri "$env:N8N_URL/api/v1/workflows" `
  -Method POST -Headers $headers -Body $json -UseBasicParsing
$id = ($resp.Content | ConvertFrom-Json).data.id

# Activate
Invoke-WebRequest -Uri "$env:N8N_URL/api/v1/workflows/$id" `
  -Method PATCH -Headers $headers -Body (@{active = $true} | ConvertTo-Json) -UseBasicParsing
```

---

## Common Patterns

### Deploy & Activate
```powershell
$resp = Invoke-WebRequest -Uri "$url/api/v1/workflows" -Method POST ...
$id = ($resp.Content | ConvertFrom-Json).data.id
Invoke-WebRequest -Uri "$url/api/v1/workflows/$id" -Method PATCH -Body '{"active":true}'
Write-Host "✓ Ready: $id"
```

### Deploy, Test, Alert
```powershell
$resp = Invoke-WebRequest -Uri "$url/api/v1/workflows" -Method POST ...
$id = ($resp.Content | ConvertFrom-Json).data.id
Invoke-WebRequest -Uri "$url/api/v1/workflows/$id" -Method PATCH -Body '{"active":true}'

$test = Invoke-WebRequest -Uri "$url/webhook/path" -Method POST -Body $payload

if ($test.StatusCode -eq 200) {
    Write-Host "✓ Success"
} else {
    Write-Host "✗ Failed"
}
```

---

## Error Handling

| Error | Cause | Solution |
|-------|-------|----------|
| `404 webhook not registered` | Not activated | PATCH with `active: true` |
| `active is read-only` | Sent in POST | Remove before POST, add in PATCH |
| `401 Unauthorized` | Invalid API key | Check `N8N_API_KEY` env var |
| `Invalid JSON` | Malformed JSON | Validate with `ConvertFrom-Json` |
| `Connection refused` | N8N not running | Start with `docker-compose up` |

---

## Security Checklist

- [ ] No credentials in JSON (use `{{$env.VAR}}`)
- [ ] `.scr/.env` has all credentials
- [ ] `.gitignore` includes `.scr/`, `*.env`
- [ ] API key in environment variable
- [ ] Webhook path is meaningful
- [ ] HTTPS for production
- [ ] API key rotated after dev
- [ ] No secrets in execution logs

---

## Real Example: Cindy-Telegram

```powershell
# Sprint S2 Production Deployment
# 1. Extracted JSON from UI
# 2. Identified credentials
# 3. Cleaned read-only fields
# 4. Created via POST → ID: f0Nbq7BA3mPoxZvZ
# 5. Activated via PATCH → active: true
# 6. Tested webhook → Status 200 OK
# 7. Verified in UI → Executions flowing
# Result: ✓ Production-ready
```

---

## Best Practices

### ✅ Do
- Clean JSON before POST
- Store credentials in `.scr/.env`
- Use env references: `{{$env.VAR_NAME}}`
- Test webhook after deployment
- Monitor executions
- Version control workflow JSON
- Document deployment
- Rotate API keys

### ❌ Don't
- Hardcode credentials
- Send `active: true` in POST
- Deploy without testing
- Skip credential management
- Use same key for dev/prod
- Assume activation succeeds
- Share `.scr/.env`
- Deploy without validation

---

**Last Updated**: March 2026 (Sprint S2)  
**Status**: Production-validated
