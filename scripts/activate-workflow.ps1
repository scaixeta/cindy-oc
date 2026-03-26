$N8N_URL = 'http://localhost:5678'
$API_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzMzkwZTNlNC00NWY2LTQ3NjktODNhNi00OWQ0OGQ0MGQ5NTgiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwianRpIjoiYjA4M2UwYTgtM2U4OC00Mzk1LTg2MjktNjU5NGM5ODY3ZGRmIiwiaWF0IjoxNzc0NTUxMjQ1fQ.m0JPROZL7eQ-NHQMPDSiUk35srjEs7uOOvaCw_jbwrk'
$WORKFLOW_ID = 'Je4KkrmIOwbBESOe'

$headers = @{
    'X-N8N-API-KEY' = $API_KEY
    'Content-Type' = 'application/json'
}

$body = '{"active":true}'

Write-Host "Activating workflow: $WORKFLOW_ID" -ForegroundColor Cyan
$response = Invoke-WebRequest -Uri "$N8N_URL/api/v1/workflows/$WORKFLOW_ID" -Method PATCH -Headers $headers -Body $body -UseBasicParsing
Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
Write-Host "Workflow activated!" -ForegroundColor Green
