# Discord.md

## 1. Entendimento

Este plano implementa o uso do **Discord como superfície de gestão de portfólio e coordenação operacional** da Cindy e do time de agentes.

Princípio central:

* **Discord** = cockpit de gestão, comando, visibilidade e handoff
* **ACP/Redis** = mesh operacional entre agentes
* **Hermes/OpenCode** = execução técnica
* **Dev_Tracking / docs / bugs_log** = fonte canônica do projeto sob DOC2.5

O Discord **não substitui** a trilha canônica do projeto.

---

## 2. Objetivo

Materializar um modelo operacional em que:

* múltiplos projetos possam ser acompanhados no Discord
* a Cindy atue como coordenadora/orquestradora
* agentes especialistas recebam tarefas com fronteiras claras
* eventos importantes sejam refletidos no tracking canônico
* o PO atue por gates, não por microgestão

---

## 3. Princípios do Modelo

1. Discord não é source of truth
2. Toda execução relevante deve gerar evidência fora do chat
3. O Discord organiza o portfólio por projeto, incidente, sprint e gate
4. ACP é a malha de coordenação entre agentes
5. Cada agente deve operar com papel, tools, skills e regras próprias
6. O PO aprova plano, mudanças grandes, riscos e aceite final
7. O menor fluxo útil deve ser implementado primeiro

---

## 4. Arquitetura-Alvo

```text
PO
  ↓
Discord (cockpit de gestão)
  ↓
Cindy (orquestração)
  ↓
ACP / Redis (mesh governado)
  ↓
Agentes especialistas
  ↓
OpenCode / runtimes / tools
  ↓
Artefatos / tracking / docs / bugs_log
```

---

## 5. Escopo do Discord

### 5.1 O que o Discord fará

* receber comandos do PO e da equipe
* abrir tarefas e threads operacionais
* mostrar status operacional da Cindy
* centralizar aprovações rápidas quando os comandos de cockpit existirem
* exibir alertas de execução e falhas
* servir como painel de acompanhamento multi-projeto no futuro

### 5.2 O que o Discord não fará

* substituir `Dev_Tracking_SX.md`
* substituir `tests/bugs_log.md`
* substituir docs canônicos
* armazenar decisão canônica sem reflexo documental
* ser o único lugar da verdade do projeto

---

## 6. Estrutura Recomendada do Servidor

## 6.1 Categorias globais

* `PORTFOLIO`
* `PO_GATES`
* `AGENT_OPS`
* `INCIDENTS`
* `AUTOMATION`
* `ARCHIVE`

## 6.2 Canais globais

### PORTFOLIO

* `#portfolio-status`
* `#portfolio-roadmap`
* `#project-index`

### PO_GATES

* `#po-approvals`
* `#po-decisions`

### AGENT_OPS

* `#cindy-commands`
* `#agent-handoffs`
* `#build-review`
* `#runtime-status`

### INCIDENTS

* `#active-incidents`
* `#postmortems`

### AUTOMATION

* `#github-events`
* `#ci-cd-events`
* `#deployments`

---

## 7. Estrutura por Projeto

Cada projeto deve ter um destes modelos:

### Modelo A — Categoria por projeto

Usar quando o projeto tiver volume alto.

Exemplo:

* `PROJECT | CindyAgent`

  * `#proj-status`
  * `#proj-sprint`
  * `#proj-incidents`
  * `#proj-builds`
  * `#proj-decisions`

### Modelo B — Fórum por projeto

Usar quando o portfólio tiver muitos projetos com menor volume.

Exemplo:

* canal fórum `#projects`
* um post/thread por projeto
* tags: `active`, `blocked`, `incident`, `review`, `done`

---

## 8. Modelo de Threads

Threads serão a unidade operacional de trabalho no Discord.

Usos:

* 1 thread por tarefa relevante
* 1 thread por incidente
* 1 thread por decisão estrutural
* 1 thread por review importante

Padrão de nome:

* `TASK | <project> | <story_id>`
* `INCIDENT | <project> | <incident_id>`
* `REVIEW | <project> | <artifact>`
* `DECISION | <project> | <decision_id>`

---

## 9. Papéis Operacionais

### Cindy

* triagem
* roteamento
* criação de task envelope
* escalonamento ao PO
* consolidação de saída

### Builder

* implementação técnica
* automação
* código

### Reviewer

* QA
* validação semântica
* auditoria técnica

### Documenter

* docs
* KB
* runbooks
* tracking assistido

### PlatformOps

* runtime
* integrações
* Discord/Telegram/Hermes
* Redis/ACP
* observabilidade

---

## 10. Comandos da Cindy no Discord

## 10.1 Comandos mínimos iniciais

O runtime live do Hermes foi reduzido ao MVP mínimo abaixo:

* `/status`
* `/help`
* `/clear`

## 10.2 Comandos de cockpit ainda pendentes

Os comandos abaixo permanecem como intenção arquitetural, mas não fazem parte do catálogo vivo atual:

* `/project summary <project>`
* `/task create <project> <title>`
* `/task assign <task_id> <agent>`
* `/task status <task_id>`
* `/review request <task_id>`
* `/approve plan <task_id>`
* `/incident open <project> <title>`
* `/incident status <incident_id>`
* `/handoff <task_id> <agent>`
* `/sprint status <project>`
* `/project open`
* `/project archive`
* `/agent status`
* `/agent heartbeat`
* `/mesh status`
* `/trace <trace_id>`

### Catálogo vivo observado no runtime Hermes

O runtime atual não expõe o comando `project status` como slash command. O catálogo vivo observado no cliente Discord ficou reduzido a `/status`, `/help` e `/clear`.

O runtime atual ainda registra o teto de 100 comandos do Discord quando o catálogo de skills é expandido, mas o MVP live ficou enxuto no guild.

---

## 11. Contrato Operacional entre Discord e ACP

Toda ação relevante do Discord deve gerar um envelope para o mesh.

## 11.1 Task Envelope mínimo

* `task_id`
* `project_id`
* `source = discord`
* `requested_by`
* `channel_id`
* `thread_id`
* `agent_target`
* `priority`
* `status`
* `trace_id`
* `artifact_refs`
* `approval_state`

## 11.2 Status mínimos

* `created`
* `triaged`
* `assigned`
* `in_progress`
* `blocked`
* `review`
* `awaiting_po`
* `done`
* `archived`

---

## 12. Regras de Reflexo Canônico

Eventos que devem refletir em artefatos canônicos:

### Dev_Tracking_SX.md

* abertura de trabalho relevante aprovado
* mudança importante de estado
* decisão estrutural
* conclusão significativa

### tests/bugs_log.md

* bug real
* teste executado
* falha validada
* incidente com evidência

### docs/

* mudança estrutural
* mudança arquitetural
* alteração operacional persistente
* nova integração estável

### README.md

* apenas quando houver impacto de baseline, sprint, escopo ou operação oficial

---

## 13. Fases de Implementação

## Fase 0 — Definição canônica

Objetivo: fechar o modelo conceitual antes de ligar integrações.

Entregas:

* definição de papel do Discord
* definição de canais e categorias
* definição do contrato Discord → ACP
* definição do que vira tracking e do que fica só no chat
* confirmação do estado real da instalação no guild de teste

Estado atual:

* app do Discord validado na API
* comandos slash globais registrados
* `DISCORD_GUILD_ID` configurado no ambiente local
* catálogo do guild realinhado ao runtime Hermes atual
* MVP live reduzido a `/status`, `/help` e `/clear`

Saída esperada:

* plano validado pelo PO

## Fase 1 — Cockpit mínimo

Objetivo: ter Discord como painel real, sem automação complexa.

Entregas:

* servidor organizado
* canais base
* papéis de acesso
* Cindy/Bot presente no servidor
* comandos mínimos manuais ou semiautomáticos
* padrão de threads por tarefa/incidente
Dependência atual:

* manter o catálogo vivo sincronizado com a superfície mínima enquanto os comandos de cockpit permanecem pendentes
Saída esperada:

* gestão multi-projeto visível
* uso operacional inicial

## Fase 2 — Integração com runtime

Objetivo: ligar Discord ao fluxo real do time.

Entregas:

* bridge Discord → Cindy
* Cindy → ACP/Redis
* retorno de status do mesh para Discord
* primeiros handoffs automáticos
* primeiros eventos de build/review/status

Saída esperada:

* comando no Discord gerando tarefa real no mesh

## Fase 3 — Reflexo canônico assistido

Objetivo: garantir que o Discord não vire fonte paralela.

Entregas:

* política de espelhamento para `Dev_Tracking`
* política de espelhamento para `bugs_log`
* templates operacionais de decisão, incidente e review
* rotina de reconciliação Cindy → docs/tracking

Saída esperada:

* governança preservada sob DOC2.5

## Fase 4 — Observabilidade

Objetivo: medir o sistema como time operacional.

Entregas:

* `trace_id` por tarefa
* logs de handoff
* métricas por agente
* falhas por canal/projeto
* visibilidade de backlog operacional

Saída esperada:

* visibilidade real de fluxo

## Fase 5 — Portfólio multi-projeto maduro

Objetivo: escalar o modelo para vários projetos simultâneos.

Entregas:

* padrão por projeto
* índice de projetos no Discord
* automações por projeto
* filtros de eventos
* padrões de incidentes e reviews por stream

Saída esperada:

* cockpit de portfólio utilizável em produção

---

## 14. Ferramentas Necessárias

### Obrigatórias agora

* Discord server
* Bot/App da Cindy no Discord
* Hermes gateway
* ACP/Redis
* OpenCode
* GitHub
* `Dev_Tracking*.md`
* `tests/bugs_log.md`

### Desejáveis fase 2+

* webhooks GitHub → Discord
* eventos CI/CD → Discord
* dashboard simples de status
* observabilidade por trace

### Futuras

* integração com Azure DevOps ou equivalente
* Microsoft Agent Framework como camada de gestão consolidada
* guardrails formais de runtime

---

## 15. Riscos

### Risco 1 — Discord virar fonte paralela

Mitigação: política de reflexo canônico obrigatória.

### Risco 2 — excesso de ruído

Mitigação: threads por item, tags, canais com propósito único.

### Risco 3 — automação antes da governança

Mitigação: implementar Fase 0 antes da Fase 2.

### Risco 4 — múltiplos projetos sem isolamento

Mitigação: padrão por projeto + `project_id` em todo envelope.

### Risco 5 — agentes sem fronteira clara

Mitigação: contract-first por agente.

---

## 16. Critérios de Sucesso

O modelo será considerado funcional quando:

1. o PO conseguir abrir e acompanhar trabalho pelo Discord
2. a Cindy conseguir rotear tarefas por projeto e agente
3. threads representarem trabalho real em andamento
4. tarefas relevantes gerarem evidência no mesh
5. bugs/testes/decisões relevantes forem refletidos no canônico
6. vários projetos puderem coexistir sem confusão operacional
7. Discord não substituir `Dev_Tracking` nem docs

---

## 17. Fora de Escopo Inicial

* substituir Telegram imediatamente
* migrar toda a operação para Discord no primeiro ciclo
* usar Discord como banco definitivo de decisão
* automatizar tudo antes da definição do contrato do mesh
* implantar plataforma corporativa adicional antes de validar o fluxo mínimo

---

## 18. Decisão Recomendada

Implementar o modelo híbrido:

* **Discord como cockpit de gestão de portfólio e agentes**
* **ACP como mesh governado**
* **Cindy como orquestradora**
* **OpenCode como executor técnico**
* **tracking DOC2.5 como verdade canônica**

---

## 19. Próximo Passo Recomendado

Produzir o artefato canônico seguinte:

* `Discord_Operating_Model.md`

com:

* estrutura final de servidor
* comandos oficiais da Cindy
* eventos que geram tracking
* política de threads
* contrato Discord → ACP
* papéis e permissões
