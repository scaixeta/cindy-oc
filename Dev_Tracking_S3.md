# Dev_Tracking - Sprint S3: Fluxo Decisório DOC2.5

**Sprint**: S3 (Março 2026)
**Status**: 🔄 ATIVA
**Data Inicial**: 2026-03-26T13:45:00-ST
**Escopo**: Criar novo fluxo decisório da Cindy baseado no DOC2.5

---

## Objetivo da Sprint

Criar um fluxo decisório robusto e documentado para a Cindy que integre:
1. Gates obrigatórios DOC2.5 (preflight, governance, init)
2. Workflows de bootstrapping
3. Decisões rastreáveis com timestamp UTC
4. Validação cruzada entre artefatos canônicos

---

## Contexto

### Problema Identificado
A Cindy precisa de um fluxo decisório claro que:
- Integre os gates DOC2.5 de forma natural
- Responda perguntas antes de agir
- Valide conformidade antes de conclusões
- Mantenha rastreabilidade de todas as decisões

### Solução Proposta
Criar workflow decisório que siga a ordem de precedência DOC2.5:
```
1. rules/WORKSPACE_RULES.md (fonte operacional)
2. Regras do runtime ativo (.cline, .codex, .agents)
3. Cindy_Contract.md
4. README.md
5. Dev_Tracking.md, Dev_Tracking_SX.md, docs canônicos
```

---

## Tarefas Planejadas

### S3-01: Analisar Fluxo Decisório Atual
- [ ] Mapear fluxo decisório atual da Cindy
- [ ] Identificar pontos de melhoria
- [ ] Documentar gaps com DOC2.5

### S3-02: Criar Workflow de Bootstrap DOC2.5
- [ ] Definir perguntas de entrada (onboarding)
- [ ] Criar fluxo de inicialização
- [ ] Integrar gate de preflight

### S3-03: Implementar Gate de Governança
- [ ] Integrar rules/WORKSPACE_RULES.md
- [ ] Criar validação de precedência
- [ ] Implementar checkpoint de aprovação

### S3-04: Documentar Fluxo Decisório
- [ ] Criar KB/decisao-workflow.md
- [ ] Mapear todos os paths de decisão
- [ ] Exemplificar com casos de uso

### S3-05: Validar com Caso Real
- [ ] Testar fluxo com sprint atual
- [ ] Validar rastreabilidade
- [ ] Ajustar conforme necessário

### S3-06: Implementar Doutrina de Protecao `.env`
- [x] Criar CR-S3-ENV-01 em Wauzap/CR-S3-env-doutrina.md
- [x] Atualizar rules/WORKSPACE_RULES.md (Regra 12)
- [x] Organizar src/.env com comentarios e estrutura
- [x] Adicionar src/.env ao .gitignore
- [x] Criar .env.example como template
- [ ] Atualizar docs/SETUP.md com procedimento (opcional - revertido pelo PO)
- [ ] Criar KB/env-security.md (opcional S4)

### S3-07: Workflow n8n Telegram Auto-Reply (EM ANDAMENTO)
- [x] Criar workflow JSON: Webhook → Code → HTTP(MiniMax) → Format → Telegram
- [x] **Correções aplicadas em 2026-03-26T16:49:00-ST**:
  - Node "Extract Data": `$input.item.json` → `$input.json`
  - Node "MiniMax AI": Headers e body refatorados para sintaxe correta n8n v3
  - Node "Format Response": `$('Extract Data').first().json` → `$node["Extract Data"].json`
  - Node "Telegram": Expressões corrigidas com espaços `{{ $json.xxx }}`
- [x] **Correções críticas em 2026-03-26T17:00-17:20-ST** (Sessão final):
  - **Erro 415 (Unsupported Media Type)**: Header `Content-Type: application/json` ausente nas chamadas POST
  - **Erro 500 (Internal Server Error)**: Nó Telegram falhava com credenciais inválidas (chat_id fictício `123456789`)
  - **Solução**: Removido nó Telegram problemático, substituído por Code node + Respond to Webhook
  - **Teste**: Webhook respondendo 200 OK com dados JSON corretos
- [ ] Deploy via API n8n (workflow corrigido)
- [ ] Teste end-to-end com Telegram (com chat_id real)
- [ ] Documentar padrão em KB

**Nota**: Workflow simples (Webhook → Process → Respond) funcionando. Padrão de credenciais seguras implementado via `.scr/.env`.

---

### S3-08: Padrão Seguro de Credenciais para Scripts (CONCLUÍDO)
- [x] Implementar leitura de credenciais de `.scr/.env` em vez de hardcoded
- [x] **Script padrão** (`test-with-env.ps1`):
  ```powershell
  # Carregar variáveis do .scr/.env
  $envContent = Get-Content 'c:/Cindy-OC/.scr/.env'
  foreach ($line in $envContent) {
      if ($line -match '^([^=]+)=(.*)$') {
          $key = $matches[1]
          $value = $matches[2]
          [Environment]::SetEnvironmentVariable($key, $value, "Process")
      }
  }
  # Usar: [Environment]::GetEnvironmentVariable('N8N_API_KEY')
  ```
- [x] **Validação**: Conectividade n8n confirmada via API
- [x] **Regra**: Nunca hardcoded credenciais em scripts PowerShell ou arquivos versionados

**Padrão a ser seguido**: Todos os scripts em `/scripts/` devem seguir este padrão.

---

## Timestamps

| Evento | Timestamp | Status |
|--------|-----------|--------|
| S3 Início | 2026-03-26T13:45:00-ST | Planejado |
| S3-07 Correção Erro 415+500 | 2026-03-26T17:00:00-ST | ✅ Corrigido |
| S3-08 Padrão Credenciais | 2026-03-26T17:15:00-ST | ✅ Implementado |
| S3-08 Limpeza de Scripts | 2026-03-26T17:19:00-ST | ✅ Concluído |

---

## Dependências

- Sprint S2 concluída (skills N8N portadas)
- Estrutura .cline/.agents/.codex existente
- WORKSPACE_RULES.md como fonte operacional

---

## Critérios de Sucesso

1. Fluxo decisório documentado e operacional
2. Gate DOC2.5 integrado naturalmente
3. Rastreabilidade de decisões mantida
4. Tempo de decisão reduzido em 50%

---

**Última Atualização**: 2026-03-26T17:22:00-ST
**Responsável**: Cline (AI Assistant)
**Validação PO**: Pendente
