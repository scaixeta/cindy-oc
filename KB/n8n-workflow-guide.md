# KB - Guia Prático: Como Criar e Manter Workflows N8N na Cindy OC

## Objetivo

Documento de referência para criar, testar, implantar e manter workflows do N8N de forma simples, repetível e segura no projeto Cindy OC e em futuros projetos.

Baseado em validação prática realizada na Sprint S2 (Março 2026).

---

## 1. Princípios Essenciais

### 1.1 Workflow como Artefato Versionável

- O workflow N8N é um **JSON estruturado**, não apenas um desenho visual
- Deve ser mantido em **repositório versionado** para rastreabilidade
- Credenciais devem vir sempre de **`.env` ou secret manager**, nunca hardcoded
- Mudanças denso devem sair do canvas para **scripts locais** quando apropriado

### 1.2 Separação de Responsabilidades

| Camada | O Que Faz | Exemplo |
|--------|----------|---------|
| Canvas N8N | Desenho visual, testes rápidos | Webhook → HTTP Request → Respond |
| Código Externo | Lógica densa, SQL complexa, patches | `deploy_workflow_secure.ps1` |
| Banco | Persistência e trilha de auditoria | Postgres com executions logging |
| Variáveis Ambiente | Segredos e configuração | `.scr/.env` |

### 1.3 Ciclo Simples: Desenho → Validação → Ativação

1. **Desenho**: Criar workflow no canvas visual
2. **Validação**: Exportar JSON, validar, limpar campos desnecessários
3. **Implantação**: Enviar via API REST (`POST /api/v1/workflows`)
4. **Ativação**: Usar PATCH para ativar (`active: true`)
5. **Teste**: Chamar webhook ou trigger e validar resposta

---

## 2. Estrutura Mínima de um Workflow Funcional

### 2.1 Componentes Obrigatórios

```json
{
  "name": "Seu-Workflow-Nome",
  "nodes": [
    {
      "id": "identificador-unico",
      "name": "Nome Legível",
      "type": "n8n-nodes-base.webhook",
      "typeVersion": 2,
      "parameters": { ... },
      "position": [x, y]
    }
  ],
  "connections": {
    "NomeDoNode": {
      "main": [[{"node": "ProximoNode", "type": "main", "index": 0}]]
    }
  },
  "settings": {
    "executionOrder": "v1"
  }
}
```

### 2.2 Campos a Remover Antes de Importar

**Nunca envie via API:**

- `active: true` (é read-only)
- `id` (gerado pelo N8N)
- `versionId`
- `meta`
- `pinData`
- `tags` (opcional)

**Solução**: Use script para limpar o JSON antes de enviar.

### 2.3 Campos Essenciais para Cada Node

| Campo | Obrigatório? | Descrição |
|-------|-------------|-----------|
| `id` | Sim | Único dentro do workflow |
| `name` | Sim | Nome legível |
| `type` | Sim | Tipo do node (webhook, httpRequest, etc) |
| `typeVersion` | Sim | Versão do node |
| `parameters` | Não | Configuração específica do node |
| `position` | Não | Coordenadas visuais no canvas |

---

## 3. Padrão Recomendado: Webhook → Processamento → Resposta

### 3.1 Estrutura Padrão

```
Webhook (POST) 
  ↓
HTTP Request [opcional]
  ↓
Respond to Webhook
```

### 3.2 Implementação Mínima

**Node 1: Webhook**
```json
{
  "id": "webhook-node",
  "name": "Webhook",
  "type": "n8n-nodes-base.webhook",
  "typeVersion": 2,
  "parameters": {
    "httpMethod": "POST",
    "path": "seu-webhook-path",
    "options": {}
  },
  "position": [250, 300]
}
```

**Node 2: Respond**
```json
{
  "id": "respond-node",
  "name": "Respond to Webhook",
  "type": "n8n-nodes-base.respondToWebhook",
  "typeVersion": 1,
  "parameters": {
    "responseBody": "{\"status\":\"ok\",\"message\":\"Recebido\"}",
    "options": {}
  },
  "position": [500, 300]
}
```

**Conexões**
```json
{
  "Webhook": {
    "main": [[{"node": "Respond to Webhook", "type": "main", "index": 0}]]
  }
}
```

### 3.3 URL de Acesso Após Ativação

```
POST http://127.0.0.1:5678/webhook/seu-webhook-path
```

---

## 4. Passo a Passo: Criar e Implantar um Workflow

### 4.1 Passo 1: Desenho Visual (Canvas)

1. Abra N8N: `http://127.0.0.1:5678`
2. Clique em **New** ou **Workflows**
3. Arraste um node **Webhook** para o canvas
4. Configure `path`: ex. `cindy-telegram`
5. Arraste um node **Respond to Webhook**
6. Conecte: Webhook → Respond
7. Clique **Save** (não precisa ativar aqui)

### 4.2 Passo 2: Exportar e Validar JSON

**Opção A: Via UI**
1. No editor, clique em **menu (⋯)**
2. Selecione **Download** ou **Export**
3. Salve como `workflow_name.json`

**Opção B: Via API**
```powershell
$headers = @{ "X-N8N-API-KEY" = $API_KEY }
$response = Invoke-WebRequest -Uri "http://127.0.0.1:5678/api/v1/workflows/$WORKFLOW_ID" `
  -Headers $headers -UseBasicParsing
$response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 10 > workflow.json
```

### 4.3 Passo 3: Limpar JSON

Remove campos read-only:

```powershell
# Carregar JSON
$json = Get-Content workflow.json | ConvertFrom-Json

# Remover campos
$json.PSObject.Properties.Remove('active')
$json.PSObject.Properties.Remove('id')
$json.PSObject.Properties.Remove('versionId')
$json.PSObject.Properties.Remove('meta')

# Salvar
$json | ConvertTo-Json -Depth 10 | Set-Content workflow_clean.json
```

### 4.4 Passo 4: Enviar via API

```powershell
$headers = @{
  "X-N8N-API-KEY" = $API_KEY
  "Content-Type" = "application/json"
}

$json = Get-Content workflow_clean.json -Raw

$response = Invoke-WebRequest -Uri "http://127.0.0.1:5678/api/v1/workflows" `
  -Method POST -Headers $headers -Body $json -UseBasicParsing

$data = $response.Content | ConvertFrom-Json
$WORKFLOW_ID = $data.data.id
Write-Host "Workflow criado: $WORKFLOW_ID"
```

### 4.5 Passo 5: Ativar Workflow

```powershell
$activateBody = @{ active = $true } | ConvertTo-Json

$response = Invoke-WebRequest -Uri "http://127.0.0.1:5678/api/v1/workflows/$WORKFLOW_ID" `
  -Method PATCH -Headers $headers -Body $activateBody -UseBasicParsing

Write-Host "Workflow ativado"
```

### 4.6 Passo 6: Testar Webhook

```powershell
$testPayload = @{ text = "Teste" } | ConvertTo-Json

$response = Invoke-WebRequest -Uri "http://127.0.0.1:5678/webhook/seu-webhook-path" `
  -Method POST -Body $testPayload -ContentType "application/json" -UseBasicParsing

Write-Host "Status: $($response.StatusCode)"
Write-Host "Response: $($response.Content)"
```

---

## 5. Padrões Comuns e Como Implementar

### 5.1 Webhook → HTTP Request → Respond

**Use Case**: Receber dados, chamar API externa, retornar resposta

**Estrutura**:
```
Webhook → HTTP Request → Respond
```

**Configuração HTTP Request**:
```json
{
  "id": "http-node",
  "name": "Call API",
  "type": "n8n-nodes-base.httpRequest",
  "typeVersion": 4.1,
  "parameters": {
    "method": "POST",
    "url": "https://api.exemplo.com/endpoint",
    "sendHeaders": true,
    "headerParameters": {
      "parameters": [
        {"name": "Authorization", "value": "Bearer {{$env.API_TOKEN}}"}
      ]
    },
    "sendBody": true,
    "bodyParameters": {
      "parameters": [
        {"name": "text", "value": "{{$json.text}}"}
      ]
    }
  }
}
```

### 5.2 Webhook → Banco de Dados → Respond

**Use Case**: Receber dados, salvar em DB, retornar confirmação

**Estrutura**:
```
Webhook → Postgres → Respond
```

**Configuração Postgres**:
```json
{
  "id": "db-node",
  "name": "Save to DB",
  "type": "n8n-nodes-base.postgres",
  "typeVersion": 2.4,
  "parameters": {
    "operation": "executeQuery",
    "query": "INSERT INTO events (text, created_at) VALUES ('{{$json.text}}', NOW())",
    "options": {}
  }
}
```

### 5.3 Cron/Schedule → Processamento → Notificação

**Use Case**: Executar diariamente, processar dados, notificar resultado

**Use node**: Schedule (Cron)
```json
{
  "id": "cron-node",
  "name": "Daily Schedule",
  "type": "n8n-nodes-base.cron",
  "parameters": {
    "cronExpression": "0 9 * * *",
    "options": {}
  }
}
```

---

## 6. Tratamento de Credenciais

### 6.1 Nunca Hardcode Segredos

❌ **Errado**:
```json
"value": "sk-cp-abc123xyz"
```

✅ **Correto**:
```json
"value": "{{$env.MINIMAX_API_KEY}}"
```

### 6.2 Injetar Variáveis de Ambiente

No `docker-compose.yml` ou variáveis N8N:

```yaml
environment:
  - MINIMAX_API_KEY=${MINIMAX_API_KEY}
  - TELEGRAM_BOT_TOKEN=${TELEGRAM_BOT_TOKEN}
```

### 6.3 Acessar em Parâmetros

```json
"parameters": {
  "headerParameters": {
    "parameters": [
      {"name": "Authorization", "value": "Bearer {{$env.MINIMAX_API_KEY}}"}
    ]
  }
}
```

---

## 7. Debugging e Troubleshooting

### 7.1 Erros Comuns e Soluções

| Erro | Causa | Solução |
|------|-------|---------|
| `404 webhook not registered` | Workflow não ativado | Ativar via PATCH com `active: true` |
| `request/body/active is read-only` | Enviando `active: true` no POST | Remover campo antes de criar, ativar depois |
| `PATCH method not allowed` | URL incorreta ou versão N8N antigo | Verificar URL: `/api/v1/workflows/{id}` |
| `Unauthorized` | API key inválida | Verificar `N8N_API_KEY` em `.env` |
| `Invalid JSON` | Formatação incorreta | Validar com `python -m json.tool` |

### 7.2 Validar Webhook Está Funcionando

```powershell
# 1. Verificar se workflow está ativo
$response = Invoke-WebRequest -Uri "http://127.0.0.1:5678/api/v1/workflows/$WORKFLOW_ID" `
  -Headers @{"X-N8N-API-KEY" = $API_KEY} -UseBasicParsing
$json = $response.Content | ConvertFrom-Json
Write-Host "Ativo: $($json.data.active)"

# 2. Testar webhook
$test = Invoke-WebRequest -Uri "http://127.0.0.1:5678/webhook/seu-path" `
  -Method POST -Body '{"test":"data"}' -ContentType "application/json" -UseBasicParsing
Write-Host "Status: $($test.StatusCode)"
```

### 7.3 Ver Logs de Execução

No N8N, clique em **Executions** para ver histórico de chamadas:
- Request recebido
- Parâmetros extraídos
- Resposta enviada
- Erros

---

## 8. Segurança: Checklist Obrigatório

- [ ] Nenhuma credencial em hardcode
- [ ] Todas as keys vêm de `$env.`
- [ ] `.scr/.env` não é versionado (`.gitignore`)
- [ ] API key do N8N é rotacionado após desenvolvimento
- [ ] Webhook está autenticado ou em rede privada
- [ ] HTTP requests usem HTTPS quando possível
- [ ] Timeout configurado (evita travamento)
- [ ] Responses não expõem informação sensível

---

## 9. Scripts Reutilizáveis da Sprint S2

Estão disponíveis em `c:\Cindy-OC\`:

- `deploy_workflow_secure.ps1` - Deploy e ativação automática
- `confirm_workflow.ps1` - Listar workflows ativos
- `workflow_simple.json` - Template Webhook → Respond

**Como usar**:

```powershell
# Deploy
pwsh -ExecutionPolicy Bypass -File deploy_workflow_secure.ps1

# Validar
pwsh -ExecutionPolicy Bypass -File confirm_workflow.ps1
```

---

## 10. Próximos Passos e Evolução

Após dominar o padrão básico:

1. **Adicionar validação**: Node `Code` para validar payload
2. **Adicionar persistência**: Salvar em Postgres
3. **Adicionar notificação**: Enviar para Telegram ou email
4. **Adicionar erro handling**: Try-catch com dead-letter queue
5. **Adicionar observabilidade**: Logs estruturados com correlation ID

---

## 11. Referências

- N8N Docs: https://docs.n8n.io/
- KB KB/railway-n8n-server-communication-patterns.md
- Relatório MLE: Migrations e diagnósticos prévios
- Dev_Tracking_S2.md: Histórico desta sprint

---

**Última Atualização**: Março 26, 2026 (Sprint S2)
**Status**: Validado e operacional
