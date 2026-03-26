# PROMPT: Validação Arquitetural - Cindy Orchestrator Docker

**Destinatário:** Cindy (via MiniMax 2.7)  
**Papel:** Arquiteto de Software + Engenheiro de Dados + Engenheiro de Software  
**Contexto:** Revisão técnica completa da containerização da Cindy OC  
**Ação:** VALIDAR e TESTAR (NÃO executar)

---

## 1. Contexto do Pedido

O Cline (agente local) gerou uma **arquitetura completa de containerização** para a Cindy AI Orchestrator, portando todo o conhecimento local (Skills, KB, Docs, Governança DOC2.5) para Docker.

**Você deve atuar como:**
1. **Arquiteto de Software**: Validar decisões de design, padrões e trade-offs
2. **Engenheiro de Dados**: Validar migração e persistência de conhecimento
3. **Engenheiro DevOps**: Validar práticas Docker, segurança e observabilidade

**O que NÃO fazer:**
- ❌ NÃO executar nenhum código
- ❌ NÃO fazer build da imagem
- ❌ NÃO rodar containers
- ❌ NÃO fazer deploy

**O que FAZER:**
- ✅ Revisar arquitetura proposta
- ✅ Validar Dockerfile multi-stage
- ✅ Validar docker-compose.yml
- ✅ Validar estratégia de migração de conhecimento
- ✅ Identificar problemas, riscos e melhorias
- ✅ Propor ajustes se necessário

---

## 2. Artefatos Gerados (Para Revisão)

### 2.1 Dockerfile Multi-Stage

**Arquivo:** `Dockerfile.cindy-orchestrator`

**Validar:**
- [ ] Stage 1 (builder): Instalação de dependências está otimizada?
- [ ] Stage 2 (knowledge): Discovery de skills/KB/docs está correto?
- [ ] Stage 3 (runtime): Imagem final está segura e mínima?
- [ ] Uso de Alpine Linux é adequado?
- [ ] User `node` (não root) está configurado corretamente?
- [ ] Health check está integrado?
- [ ] Variáveis de ambiente estão bem definidas?

**Questões arquiteturais:**
1. O approach multi-stage é apropriado para este caso?
2. A geração de índices JSON no build é uma boa estratégia?
3. Há alternativas melhores para discovery de skills?
4. O tamanho estimado (~150MB) é aceitável?

### 2.2 Docker Compose Production

**Arquivo:** `docker-compose.production.yml`

**Validar:**
- [ ] Configuração de serviços está correta?
- [ ] Dependências (`depends_on`) estão corretas?
- [ ] Health checks estão configurados adequadamente?
- [ ] Volumes persistentes estão mapeados corretamente?
- [ ] Rede Docker está bem definida?
- [ ] Variáveis de ambiente estão seguras?
- [ ] Profiles (cache, full) estão bem implementados?

**Questões arquiteturais:**
1. A estratégia de volumes (state, logs, cache) é adequada?
2. O uso de Redis como profile opcional faz sentido?
3. A integração com n8n está bem desenhada?
4. Faltam serviços críticos?

### 2.3 Scripts Shell

**Arquivos:** `docker/entrypoint.sh`, `docker/healthcheck.sh`

**Validar:**
- [ ] Preflight checks são suficientes?
- [ ] Discovery de skills no entrypoint está correto?
- [ ] Verificação de governança DOC2.5 está implementada?
- [ ] Conectividade com n8n é validada adequadamente?
- [ ] Health check valida os critérios corretos?
- [ ] Tratamento de erros está robusto?
- [ ] Scripts são idempotentes?

**Questões arquiteturais:**
1. Os checks de inicialização são completos?
2. O health check captura os sinais certos?
3. Há race conditions potenciais?

### 2.4 Core Orchestrator Engine

**Arquivo:** `src/orchestrator.js`

**Validar:**
- [ ] Classe `CindyOrchestrator` está bem estruturada?
- [ ] Discovery de skills/KB/docs está implementado corretamente?
- [ ] Roteamento de mensagens é extensível?
- [ ] Governança DOC2.5 está integrada?
- [ ] Persistência de estado está implementada?
- [ ] Tratamento de erros é adequado?
- [ ] Logging está estruturado?

**Questões arquiteturais:**
1. A arquitetura de routing é escalável?
2. O approach de discovery via índices JSON é eficiente?
3. A separação de responsabilidades está clara?
4. Há acoplamentos problemáticos?

### 2.5 Configuração de Ambiente

**Arquivo:** `.env.docker.example`

**Validar:**
- [ ] Todas as variáveis necessárias estão presentes?
- [ ] Valores default são sensatos?
- [ ] Variáveis sensíveis estão documentadas?
- [ ] Separação de concerns (core, telegram, n8n, openclaw) é clara?
- [ ] Comentários são úteis?

**Questões arquiteturais:**
1. Faltam configurações críticas?
2. Há variáveis redundantes ou desnecessárias?

### 2.6 Documentação

**Arquivos:**
- `docs/DOCKER_DEPLOYMENT.md`
- `docs/KNOWLEDGE_MIGRATION.md`
- `DOCKER_README.md`

**Validar:**
- [ ] Documentação está completa?
- [ ] Exemplos de comandos estão corretos (PowerShell)?
- [ ] Fluxo de deployment está claro?
- [ ] Troubleshooting cobre os casos comuns?
- [ ] Estratégia de migração está bem explicada?
- [ ] Diagramas e tabelas estão claros?

---

## 3. Migração de Conhecimento (Crítico)

### 3.1 O que é Portado

| Artefato Local | Destino Docker | Estratégia |
|---|---|---|
| `.cline/skills/` | `/app/.cline/skills/` | Cópia + índice JSON |
| `KB/` | `/app/KB/` | Cópia completa |
| `docs/` | `/app/docs/` | Cópia completa |
| `Templates/` | `/app/Templates/` | Cópia completa |
| `rules/` | `/app/rules/` | Cópia completa |
| `Cindy_Contract.md` | `/app/Cindy_Contract.md` | Cópia |

### 3.2 Validar Migração

**Perguntas:**
1. Todos os artefatos essenciais foram incluídos?
2. A estratégia de índices JSON é robusta?
3. Como garantir sincronização entre local e Docker?
4. O que acontece quando skills são adicionadas/removidas?
5. A governança DOC2.5 é preservada no Docker?

### 3.3 Índices JSON Gerados

**Exemplo esperado de `skills-index.json`:**

```json
{
  "skills": [
    "n8n-workflow-patterns",
    "n8n-workflow-deployment",
    "docker-specialist",
    "doc25-governance",
    "..."
  ]
}
```

**Validar:**
- O comando `find` no Dockerfile gera o formato correto?
- O índice é lido corretamente pelo `orchestrator.js`?
- Há tratamento de erros se o índice estiver malformado?

---

## 4. Arquitetura Proposta

### 4.1 Stack Completo

```
┌─────────────────────────────────────────────────────────┐
│                   Docker Stack                           │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │     cindy-orchestrator (Custom Build)            │   │
│  │  - Node.js 18 Alpine                             │   │
│  │  - Skills Discovery (42+ skills)                 │   │
│  │  - KB & Docs embedded                            │   │
│  │  - DOC2.5 Governance                             │   │
│  │  - Health checks                                 │   │
│  │  - Port 9090 (metrics - future)                  │   │
│  └────────────┬─────────────────────────────────────┘   │
│               │                                          │
│  ┌────────────▼─────────────────────────────────────┐   │
│  │     n8n-local (Official n8n image)               │   │
│  │  - SQLite persistence                            │   │
│  │  - Workflow engine                               │   │
│  │  - Webhook receiver                              │   │
│  │  - Port 5678 (UI)                                │   │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │     redis-cache (Optional profile)               │   │
│  │  - Cache layer                                   │   │
│  │  - Session storage                               │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

### 4.2 Validar Arquitetura

**Perguntas críticas:**
1. A separação de responsabilidades está clara?
2. O orchestrator é stateless ou stateful?
3. Como escalar horizontalmente (se necessário)?
4. A dependência com n8n está bem gerenciada?
5. Redis como opcional é uma boa decisão?
6. Faltam componentes essenciais?

### 4.3 Volumes e Persistência

```yaml
volumes:
  cindy-state:/app/state      # Estado do orchestrator
  cindy-logs:/app/logs        # Logs rotacionados
  cindy-cache:/app/cache      # Cache temporário
  n8n-data:/home/node/.n8n    # Workflows n8n
```

**Validar:**
- Estratégia de backup está clara?
- Volumes críticos estão identificados?
- Há risco de perda de dados?

---

## 5. Segurança

### 5.1 Checklist de Segurança

**Validar:**
- [ ] Container roda como usuário `node` (não root)?
- [ ] Secrets não estão hardcoded?
- [ ] `.env` está no `.gitignore`?
- [ ] Encryption keys são fortes?
- [ ] Portas expostas são mínimas?
- [ ] Health checks não vazam informações sensíveis?
- [ ] Imagem base (Alpine) é mantida atualizada?

### 5.2 Questões

1. Há vetores de ataque evidentes?
2. Como proteger variáveis de ambiente sensíveis?
3. A estratégia de secrets management é adequada?

---

## 6. Observabilidade

### 6.1 Logging

**Implementado:**
- Stdout/stderr do container
- Arquivo rotacionado em `/app/logs/`
- Structured logging (planejado)

**Validar:**
- Logs são suficientes para troubleshooting?
- Rotação de logs está configurada?
- Há PII (Personally Identifiable Information) nos logs?

### 6.2 Métricas

**Planejado:**
- Porta 9090 para métricas
- Estado persistido em JSON

**Validar:**
- Métricas planejadas são úteis?
- Formato de métricas é adequado?
- Integração com Prometheus seria viável?

### 6.3 Health Checks

**Verificado:**
1. Arquivo de estado existe
2. Processo Node.js está rodando
3. Taxa de erro < 30%
4. Logs não estão stale (< 5min)

**Validar:**
- Checks são suficientes?
- Thresholds são adequados?
- Há falsos positivos/negativos?

---

## 7. Governança DOC2.5 no Docker

### 7.1 Como é Preservada

- `rules/WORKSPACE_RULES.md` embedado na imagem
- `Cindy_Contract.md` copiado
- Validação no entrypoint
- Check de governança em `orchestrator.js`

### 7.2 Validar

**Perguntas:**
1. A governança DOC2.5 é efetiva no ambiente Docker?
2. Gates obrigatórios são respeitados?
3. Como rastrear decisões em containers efêmeros?
4. A política de commits/push é preservada?

---

## 8. Testes Sugeridos (Sem Executar)

### 8.1 Testes de Build

```powershell
# 1. Build da imagem
docker compose -f docker-compose.production.yml build

# Validar:
# - Build completa sem erros?
# - Tamanho da imagem é aceitável?
# - Todas as stages funcionaram?
```

### 8.2 Testes de Discovery

```powershell
# 2. Verificar índices gerados
docker exec cindy-orchestrator cat /app/skills-index.json
docker exec cindy-orchestrator cat /app/kb-index.json
docker exec cindy-orchestrator cat /app/docs-index.json

# Validar:
# - Índices estão corretos?
# - Todas as skills foram descobertas?
# - Formato JSON é válido?
```

### 8.3 Testes de Runtime

```powershell
# 3. Verificar inicialização
docker logs cindy-orchestrator | Select-String "PREFLIGHT|DISCOVERY|GOVERNANCE"

# Validar:
# - Todos os checks passaram?
# - Skills foram carregadas?
# - n8n conectou?
```

### 8.4 Testes de Health

```powershell
# 4. Verificar saúde
docker inspect cindy-orchestrator --format='{{.State.Health.Status}}'

# Validar:
# - Status é "healthy"?
# - Health check executa corretamente?
```

### 8.5 Testes de Persistência

```powershell
# 5. Verificar estado
docker exec cindy-orchestrator cat /app/state/orchestrator.json

# Validar:
# - Estado é gravado corretamente?
# - Stats são atualizados?
```

---

## 9. Riscos e Limitações

### 9.1 Riscos Identificados

1. **Sincronização Local ↔ Docker**: Como manter skills atualizadas?
2. **Build Time**: Rebuild completo a cada mudança pode ser lento
3. **Estado em Container**: Como garantir persistência em caso de falha?
4. **Discovery Estático**: Índices JSON podem ficar desatualizados
5. **Escalabilidade**: Arquitetura atual suporta múltiplas instâncias?

### 9.2 Limitações Conhecidas

1. OpenClaw ainda não está implementado (placeholder)
2. Métricas (porta 9090) são planejadas, não implementadas
3. Redis é opcional e não integrado ao core
4. Skills discovery é read-only (não há reload dinâmico)

---

## 10. Checklist de Validação (Para Você, Cindy)

### 10.1 Arquitetura

- [ ] Dockerfile multi-stage está bem estruturado?
- [ ] docker-compose.yml está correto e completo?
- [ ] Separação de concerns está clara?
- [ ] Há single points of failure?

### 10.2 Código

- [ ] `orchestrator.js` está bem implementado?
- [ ] Discovery de skills/KB/docs é robusto?
- [ ] Roteamento de mensagens é extensível?
- [ ] Tratamento de erros é adequado?

### 10.3 Operações

- [ ] Scripts shell (`entrypoint.sh`, `healthcheck.sh`) são robustos?
- [ ] Preflight checks são suficientes?
- [ ] Health checks capturam os sinais certos?
- [ ] Logging é adequado?

### 10.4 Segurança

- [ ] Container roda como não-root?
- [ ] Secrets não estão expostos?
- [ ] Imagem base é segura?
- [ ] Portas expostas são mínimas?

### 10.5 Documentação

- [ ] Guias de deployment estão completos?
- [ ] Comandos PowerShell estão corretos?
- [ ] Troubleshooting cobre casos comuns?
- [ ] Migração de conhecimento está clara?

### 10.6 DOC2.5

- [ ] Governança é preservada no Docker?
- [ ] Rastreabilidade é mantida?
- [ ] Gates obrigatórios são respeitados?
- [ ] Contrato canônico está embedado?

---

## 11. Output Esperado (Sua Resposta)

Por favor, forneça uma **análise estruturada** com:

### 11.1 Validação Geral

```
✅ APROVADO | ⚠️ APROVADO COM RESSALVAS | ❌ REJEITAR

Justificativa: [sua análise]
```

### 11.2 Pontos Fortes

Liste as decisões arquiteturais acertadas.

### 11.3 Problemas Identificados

Liste problemas críticos, severos ou moderados encontrados.

**Formato:**

```
🔴 CRÍTICO: [descrição do problema]
   Impacto: [qual o impacto]
   Sugestão: [como resolver]

🟡 SEVERO: [descrição]
   Impacto: [impacto]
   Sugestão: [solução]

🟢 MODERADO: [descrição]
   Sugestão: [melhoria]
```

### 11.4 Melhorias Sugeridas

Liste otimizações e melhorias arquiteturais.

### 11.5 Questões para o PO

Liste decisões que precisam de aprovação do Product Owner.

### 11.6 Próximos Passos Recomendados

Se aprovado, qual o roadmap sugerido?

**Exemplo:**

1. Ajustar [X] conforme feedback
2. Testar build localmente
3. Validar discovery de skills
4. Deploy em ambiente de teste
5. Validação funcional completa

---

## 12. Contexto Adicional

### 12.1 Histórico do Projeto

- Sprint S0: Bootstrap do projeto
- Sprint S1: Telegram MVP funcionando
- Sprint S2: Integração com n8n, 6 testes passando
- Sprint S3 (atual): Fluxo decisório DOC2.5 + **Containerização**

### 12.2 Ferramentas no Stack

- Docker Engine 20.10+
- Docker Compose 2.0+
- Node.js 18 (Alpine)
- n8n (latest)
- Redis 7 (opcional)

### 12.3 Ambiente Alvo

- Windows 11 (desenvolvimento local)
- PowerShell como shell primário
- Railway (deployment futuro planejado)

---

## 13. Entrega Final

**Formato da sua resposta:**

1. **Executive Summary**: Visão geral da validação (1 parágrafo)
2. **Análise Detalhada**: Seções 11.1 a 11.6
3. **Conclusão**: Recomendação final (aprovar/ajustar/rejeitar)

**Tom:** Técnico, objetivo, baseado em evidências e boas práticas.

---

**Pronto para sua análise, Cindy! 🚀**
