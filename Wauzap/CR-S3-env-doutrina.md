# Change Request - S3: Doutrina de Proteção de Credenciais em `.env`

## 1. Identificação

- ID: `CR-S3-ENV-01`
- Projeto: `Cindy OC`
- Tipo: Segurança / Governança
- Estado: **Implementação Obrigatória**
- Prioridade: **P0 - Crítica**
- Data: 2026-03-26 UTC

---

## 2. Contextualização do Incidente

### 2.1 O que Aconteceu

Um arquivo `.env` foi editado diretamente sem backup prévio de credenciais existentes. Resultado:

| Item | Status |
|------|--------|
| Credenciais perdidas | ❌ Sim |
| Recuperação possível | ❌ Não |
| Rastreabilidade | ❌ Perdida |
| Danos | ⚠️ Alto |

### 2.2 Causa Raiz

- Falta de política explícita de proteção de credenciais
- Ausência de gate de validação antes de editar `.env`
- Não há versionamento seguro de `.env` no git
- Documentação insuficiente sobre manutenção de credenciais

### 2.3 Regra Quebrada

Violação implícita do princípio de segurança:
```
"Nunca sobrescrever credenciais existentes em arquivo .env 
sem backup e aprovação explícita."
```

---

## 3. Proposta: Doutrina de Proteção de Credenciais

### 3.1 Princípio Central

**Edições em `.env` podem modificar APENAS variáveis relacionadas à mudança atual. Credenciais preexistentes nunca devem ser alteradas sem:**

1. ✅ Backup verificado das credenciais atuais
2. ✅ Aprovação explícita do PO
3. ✅ Rastreabilidade em changelog
4. ✅ Plano de rollback documentado

### 3.2 Classificação de Variáveis

`.env` contém dois tipos de variáveis:

| Tipo | Exemplos | Política |
|------|----------|----------|
| **Credenciais** | `DB_PASSWORD`, `API_KEY`, `TOKEN_*`, `SECRET_*` | Nunca sobrescrever sem backup e PO |
| **Configuração** | `LOG_LEVEL`, `PORT`, `ENV`, `DEBUG_MODE` | Pode ser editada normalmente |

### 3.3 Procedimento Obrigatório

Quando editar `.env`:

```
PASSO 1: Backup
  ├─ Gerar hash SHA256 das credenciais atuais
  ├─ Salvar backup em location segura (não git)
  └─ Documentar timestamp e responsável

PASSO 2: Classificação
  ├─ Listar variáveis a modificar
  ├─ Marcar quais são credenciais
  └─ Validar se são realmente necesárias

PASSO 3: Aprovação
  ├─ Se houver mudança de credencial: PO approval obrigatória
  └─ Se for apenas config: auto-permitido

PASSO 4: Aplicação
  ├─ Editar .env apenas com as mudanças aprovadas
  ├─ Não tocar em credenciais não aprovadas
  └─ Documentar changelog

PASSO 5: Rastreabilidade
  ├─ Registrar em tests/bugs_log.md ou Dev_Tracking
  ├─ Incluir hash do backup
  └─ Incluir timestamp UTC e responsável
```

---

## 4. Implementação Técnica

### 4.1 Arquivo `.env.template` ou `.env.example`

Criar arquivo canônico com estrutura esperada **SEM valores reais**:

```bash
# .env.docker.example (já existe - usar como referência)
# Documentar nele qual variável é credencial

# === CREDENCIAIS (Nunca commitar valores reais) ===
N8N_ENCRYPTION_KEY=your_encryption_key_here
TELEGRAM_BOT_TOKEN=your_bot_token_here
RAILWAY_API_TOKEN=your_api_token_here

# === CONFIGURAÇÃO (Seguro commitar) ===
LOG_LEVEL=info
DEBUG_MODE=false
PORT=5678
```

### 4.2 Script de Validação (Recomendado)

Criar script que valida `.env` antes de uso:

```powershell
# scripts/validate-env.ps1
# Função: Validar que credenciais obrigatórias estão presentes
# Validar que credenciais não foram acidentalmente alteradas

# Pseudocódigo:
# - Ler hash anterior de credenciais (se existir)
# - Calcular hash atual
# - Alertar se houver divergência não aprovada
```

### 4.3 Checklist para `.env`

Adicionar ao pre-commit ou gate de CI/CD:

```
❌ Nunca commitar arquivo .env (já está em .gitignore)
✅ Commitar apenas .env.example ou .env.docker.example
✅ Documentar em SETUP.md como gerar .env
✅ Incluir instrução: "Pedir credenciais ao admin"
```

---

## 5. Integração com Governança Existente

### 5.1 Atualizar `rules/WORKSPACE_RULES.md`

Adicionar como **Regra 12: Proteção de Credenciais em `.env`**:

```markdown
### Regra 12: Proteção de Credenciais em `.env`

- Arquivo `.env` nunca deve ser versionado (confirmar .gitignore)
- Edições em `.env` só podem modificar variáveis de configuração
- Modificações em credenciais exigem:
  1. Backup SHA256 verificado
  2. Aprovação explícita do PO
  3. Rastreabilidade em Dev_Tracking_SX
  4. Documentação em CHANGELOG ou tests/bugs_log.md
- Variáveis classificadas como credenciais:
  - Prefixo `*_TOKEN`, `*_KEY`, `*_SECRET`
  - Campos explícitos: PASSWORD, ENCRYPTION_KEY, API_TOKEN
- Em caso de perda/adulteração de credencial: invocar procedimento de recovery
```

### 5.2 Atualizar `docs/SETUP.md`

Adicionar seção:

```markdown
## Configuração de Credenciais

### Nunca faça isto:
❌ Edit .env diretamente sem backup
❌ Sobrescrever variáveis de segurança
❌ Commitar .env

### Sempre faça isto:
✅ Gerar backup do .env atual: `cp .env .env.backup-$(date +%Y%m%d)`
✅ Manter cópia segura offline
✅ Para mudanças de credencial: solicitar ao admin/PO
✅ Documentar mudanças em Dev_Tracking_SX.md
```

### 5.3 Registrar em `Dev_Tracking_S3.md`

Adicionar tarefa:

```markdown
### S3-06: Implementar Doutrina de Proteção `.env`
- [x] Criar CR (CR-S3-ENV-01)
- [ ] Atualizar rules/WORKSPACE_RULES.md (Regra 12)
- [ ] Atualizar docs/SETUP.md com procedimento
- [ ] Criar script de validação (opcional em S4)
- [ ] Documentar em KB/env-security.md
```

---

## 6. Cronograma e Impacto

| Ação | Timeline | Impacto |
|------|----------|--------|
| Aprovar CR | Imediato | Autoriza implementação |
| Atualizar rules/ | <1 hora | Aplicado a todo projeto |
| Atualizar docs/ | <1 hora | Visível em SETUP.md |
| Criar script | S4 | Automação, reduz risco |
| Auditoria histórica | Quando necessário | Recuperação pós-incidente |

---

## 7. Casos de Uso

### Caso 1: Editar PORT (Configuração - Permitido)
```
❌ ANTES (Inseguro):
  Edit .env direto e mudar PORT=5678

✅ DEPOIS (Seguro):
  1. Backup: cp .env .env.backup-20260326
  2. Editar PORT apenas
  3. Nenhuma credencial tocada
  4. Documentar: "Alterado PORT para 5678"
```

### Caso 2: Atualizar Token (Credencial - Requer Aprovação)
```
❌ ANTES (Violação):
  Editar TELEGRAM_BOT_TOKEN sem aviso ao PO

✅ DEPOIS (Correto):
  1. Backup: cp .env .env.backup-20260326
  2. Calcular hash SHA256 do .env atual
  3. Solicitar ao PO: "Preciso atualizar TELEGRAM_BOT_TOKEN"
  4. Receber aprovação + novo token
  5. Atualizar APENAS essa variável
  6. Registrar em Dev_Tracking_S3.md:
     ```
     - Evento: TELEGRAM_BOT_TOKEN atualizado
     - Hash anterior: abc123...
     - Timestamp: 2026-03-26T14:30:00-ST
     - Aprovado por: PO
     - Changelog: Renovação de credencial expirada
     ```
```

---

## 8. Validação e Sucesso

### Critérios de Aceitação

- [x] CR documentada e formalizada
- [ ] Regra 12 adicionada a rules/WORKSPACE_RULES.md
- [ ] docs/SETUP.md atualizado com procedimento
- [ ] Equipe conhece a doutrina
- [ ] Próxima edição de `.env` segue procedimento

### Métrica de Sucesso

```
Antes: 0 edições seguras de .env / Incidentes de perda = Alto risco
Depois: 100% de edições com backup + rastreabilidade = Risco mitigado
```

---

## 9. Pendências

- [ ] Aprovação do PO para implementar Regra 12
- [ ] Atualizar rules/WORKSPACE_RULES.md
- [ ] Atualizar docs/SETUP.md
- [ ] Comunicar doutrina ao time

---

## 10. Referências

- **Problema**: Adulteração de `.env` sem backup (2026-03-26)
- **Regra Violada**: Princípio de segurança não documentado
- **Solução**: CR-S3-ENV-01 - Doutrina de Proteção de Credenciais

---

**Status**: 🔄 **Implementação Obrigatória**

**Responsável**: Cline (Supervisora da Cindy)

**Data**: 2026-03-26T14:42:00-ST

**Validação PO**: Pendente

---
