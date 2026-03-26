# Guia de Migração: Conhecimento Local → Docker

## 1. Objetivo

Este documento explica como o conhecimento da **Cindy local** (Skills, KB, Documentação, Governança DOC2.5) é portado para o ambiente Docker, mantendo a integridade e rastreabilidade.

## 2. Comparação: Local vs Docker

| Aspecto | Cindy Local (VS Code) | Cindy Docker |
|---|---|---|
| **Runtime** | Cline/Codex no VS Code | Node.js em container |
| **Skills** | `.cline/skills/` lidas dinamicamente | Embedadas na imagem + índice JSON |
| **KB** | `KB/` no filesystem local | Copiada para `/app/KB/` |
| **Docs** | `docs/` no filesystem local | Copiadas para `/app/docs/` |
| **Governança** | `rules/WORKSPACE_RULES.md` | Mesma regra embedada |
| **Estado** | Memória do agente | Volume persistente (`cindy-state`) |
| **Logs** | Console VS Code | Volume + stdout container |

## 3. Mapeamento de Artefatos

### 3.1 Skills (`.cline/skills/`)

**Local:**
```
C:\Cindy-OC\.cline\skills\
├── n8n-workflow-patterns\
│   └── SKILL.md
├── docker-specialist\
│   └── SKILL.md
├── doc25-governance\
│   └── SKILL.md
└── ...
```

**Docker:**
```
/app/.cline/skills/
├── n8n-workflow-patterns/
├── docker-specialist/
├── doc25-governance/
└── ...

/app/skills-index.json  ← Índice gerado no build
```

**Como funciona:**

1. Durante o build (Stage 2), todas as skills são copiadas
2. Um índice JSON é gerado listando todas as skills disponíveis
3. No runtime, `orchestrator.js` lê o índice e carrega skills sob demanda

**Código relevante:**

```javascript
// src/orchestrator.js - discoverSkills()
const skillsIndexPath = path.join(__dirname, '../skills-index.json');
const data = JSON.parse(fs.readFileSync(skillsIndexPath, 'utf-8'));
const skillNames = data.skills || [];
```

### 3.2 Knowledge Base (KB/)

**Local:**
```
C:\Cindy-OC\KB\
├── Cindy-telegram.json
├── n8n-workflow-guide.md
└── railway-n8n-server-communication-patterns.md
```

**Docker:**
```
/app/KB/
├── Cindy-telegram.json
├── n8n-workflow-guide.md
└── railway-n8n-server-communication-patterns.md

/app/kb-index.json  ← Índice gerado
```

**Formato do kb-index.json:**

```json
{
  "kb": [
    "KB/Cindy-telegram.json",
    "KB/n8n-workflow-guide.md",
    "KB/railway-n8n-server-communication-patterns.md"
  ]
}
```

### 3.3 Documentação (docs/)

**Local:**
```
C:\Cindy-OC\docs\
├── SETUP.md
├── ARCHITECTURE.md
├── DEVELOPMENT.md
├── OPERATIONS.md
└── DOCKER_DEPLOYMENT.md  ← Novo!
```

**Docker:**
```
/app/docs/
├── SETUP.md
├── ARCHITECTURE.md
├── DEVELOPMENT.md
├── OPERATIONS.md
└── DOCKER_DEPLOYMENT.md

/app/docs-index.json  ← Índice gerado
```

### 3.4 Templates (Templates/)

**Local:**
```
C:\Cindy-OC\Templates\
├── README.md
├── Dev_Tracking_SX.md
├── ARCHITECTURE.md
└── ...
```

**Docker:**
```
/app/Templates/
├── README.md
├── Dev_Tracking_SX.md
├── ARCHITECTURE.md
└── ...
```

**Nota:** Templates são copiados mas não indexados (usados sob demanda).

### 3.5 Governança (rules/)

**Local:**
```
C:\Cindy-OC\rules\
└── WORKSPACE_RULES.md
```

**Docker:**
```
/app/rules/
└── WORKSPACE_RULES.md
```

**Validação no entrypoint:**

```bash
# docker/entrypoint.sh
if [ -f "/app/rules/WORKSPACE_RULES.md" ]; then
  echo "[GOVERNANCE] ✅ WORKSPACE_RULES.md found"
else
  echo "[GOVERNANCE] ⚠️  WORKSPACE_RULES.md not found"
fi
```

### 3.6 Contrato (Cindy_Contract.md)

**Local:**
```
C:\Cindy-OC\Cindy_Contract.md
```

**Docker:**
```
/app/Cindy_Contract.md
```

## 4. Processo de Build (Multi-Stage)

### Stage 1: Dependencies Builder

```dockerfile
FROM node:18-alpine AS builder
WORKDIR /build
COPY package.json package-lock.json ./
RUN npm ci --only=production
```

**Output:** `/build/node_modules/`

### Stage 2: Skills & KB Compiler

```dockerfile
FROM node:18-alpine AS knowledge
WORKDIR /knowledge

# Copy knowledge sources
COPY KB/ ./KB/
COPY .cline/skills/ ./.cline/skills/
COPY docs/ ./docs/
COPY Templates/ ./Templates/
COPY rules/ ./rules/
COPY Cindy_Contract.md ./

# Generate discovery indexes
RUN find .cline/skills -type d -maxdepth 1 -mindepth 1 -exec basename {} \; | \
    jq -R -s 'split("\n")[:-1] | {skills: .}' > skills-index.json
```

**Output:**
- `skills-index.json`
- `kb-index.json`
- `docs-index.json`

### Stage 3: Runtime Image

```dockerfile
FROM node:18-alpine

# Copy from previous stages
COPY --from=builder /build/node_modules ./node_modules
COPY --from=knowledge /knowledge/KB ./KB
COPY --from=knowledge /knowledge/.cline/skills ./.cline/skills
COPY --from=knowledge /knowledge/*.json ./
```

**Output:** Imagem final otimizada (~150MB)

## 5. Runtime Discovery

### 5.1 Inicialização do Orchestrator

```javascript
// src/orchestrator.js
async initialize() {
  if (this.skillsDiscovery === 'auto') {
    await this.discoverSkills();   // Lê skills-index.json
    await this.discoverKB();        // Lê kb-index.json
    await this.discoverDocs();      // Lê docs-index.json
  }
  this.registerRoutes();
}
```

### 5.2 Logs de Discovery

```
[DISCOVERY] Starting skills discovery...
[DISCOVERY] Loaded 42 skills from index
[DISCOVERY] Loaded 3 KB entries from index
[DISCOVERY] Loaded 5 documentation files from index
[DISCOVERY] ✅ Discovery complete
```

## 6. Persistência de Estado

### 6.1 Estado em Memória (Local)

No ambiente local (Cline/Codex), o estado é mantido na memória do agente e perdido ao reiniciar.

### 6.2 Estado Persistido (Docker)

No Docker, o estado é gravado em volume persistente:

```json
// /app/state/orchestrator.json
{
  "initialized_at": "2026-03-26T17:00:00Z",
  "mode": "docker",
  "governance": "enabled",
  "version": "1.0.0-docker",
  "stats": {
    "messages_processed": 142,
    "errors_count": 3,
    "uptime_seconds": 3600
  }
}
```

**Volume Docker:**

```yaml
volumes:
  cindy-state:
    driver: local
```

## 7. Atualizando Conhecimento

### 7.1 Adicionar Nova Skill (Local → Docker)

**Passos:**

1. Adicionar skill em `.cline/skills/nova-skill/`
2. Rebuild da imagem Docker:

```powershell
docker compose -f docker-compose.production.yml build --no-cache
docker compose -f docker-compose.production.yml up -d
```

3. Verificar discovery:

```powershell
docker exec cindy-orchestrator cat /app/skills-index.json
```

### 7.2 Atualizar KB (Local → Docker)

**Passos:**

1. Editar arquivo em `KB/novo-conhecimento.md`
2. Rebuild da imagem
3. Verificar no container:

```powershell
docker exec cindy-orchestrator ls -la /app/KB/
```

### 7.3 Hot Reload (Desenvolvimento)

Para desenvolvimento, monte volumes locais:

```yaml
# docker-compose.production.yml
volumes:
  - ./KB:/app/KB:ro
  - ./.cline/skills:/app/.cline/skills:ro
```

**Atenção:** Isso bypassa o build e usa arquivos locais diretamente.

## 8. Diferenças de Comportamento

| Comportamento | Local (Cline) | Docker |
|---|---|---|
| **Leitura de skills** | Acesso direto ao filesystem | Índice JSON pré-compilado |
| **Performance** | I/O local rápido | Cache em memória (melhor) |
| **Isolamento** | Compartilha filesystem | Container isolado |
| **Rastreabilidade** | Baseado em commits Git | Versão da imagem Docker |
| **Rollback** | `git checkout` | `docker image` anterior |

## 9. Checklist de Migração

Ao portar novo conhecimento para Docker:

- [ ] Adicionar artefato no local correto (`KB/`, `.cline/skills/`, `docs/`)
- [ ] Verificar que está no Git (se for knowledge canônico)
- [ ] Rebuild da imagem Docker
- [ ] Verificar índice JSON gerado (`skills-index.json`, etc.)
- [ ] Testar discovery no runtime
- [ ] Validar logs de inicialização
- [ ] Atualizar documentação se necessário
- [ ] Commitar mudanças (com aprovação PO)

## 10. Troubleshooting

### Problema: Skill não aparece no Docker

**Diagnóstico:**

```powershell
# 1. Verificar se foi copiada no build
docker exec cindy-orchestrator ls -la /app/.cline/skills/

# 2. Ver índice
docker exec cindy-orchestrator cat /app/skills-index.json

# 3. Ver logs de discovery
docker logs cindy-orchestrator | Select-String "DISCOVERY"
```

**Solução:** Rebuild com `--no-cache`

### Problema: KB desatualizada

**Diagnóstico:**

```powershell
# Ver data do arquivo
docker exec cindy-orchestrator stat /app/KB/arquivo.md
```

**Solução:** Rebuild da imagem

### Problema: Governança não ativa

**Diagnóstico:**

```powershell
# Verificar variável de ambiente
docker exec cindy-orchestrator env | Select-String "DOC25"

# Verificar arquivo de governança
docker exec cindy-orchestrator cat /app/rules/WORKSPACE_RULES.md
```

**Solução:** Verificar `.env` e rebuild

## 11. Versionamento

### Tagueamento de Imagens

```powershell
# Build com tag específica
docker build -f Dockerfile.cindy-orchestrator -t cindy-orchestrator:1.0.0 .

# Deploy com versão específica
docker compose -f docker-compose.production.yml up -d
```

### Rastreabilidade DOC2.5

O versionamento Docker **complementa** o DOC2.5, não substitui:

- Git commits: Rastreiam mudanças de código/conhecimento
- Docker tags: Rastreiam deployments e releases
- `Dev_Tracking_SX.md`: Rastreia decisões e contexto

---

## Referências

- [Dockerfile.cindy-orchestrator](../Dockerfile.cindy-orchestrator)
- [src/orchestrator.js](../src/orchestrator.js)
- [docker/entrypoint.sh](../docker/entrypoint.sh)
- [DOCKER_DEPLOYMENT.md](./DOCKER_DEPLOYMENT.md)
