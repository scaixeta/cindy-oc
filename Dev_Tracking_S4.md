# Dev_Tracking_S4.md — Sprint 4 (Ativa)

## Identificação
| Campo | Valor |
|---|---|
| Sprint | S4 |
| Status | **Ativa e mantida aberta** |
| Início | 2026-04-15 |
| Versão | 2.1 |
| PO | A definir |
| Objetivo | Treinamento e masterização do Cindy Agent 2026.4.14 — explorar capabilities, tools, agents e integrações |

---

## Contexto
A Sprint S4 foi reclassificada duas vezes:
1. **Primeira reclassificação:** Foco em MVP Discord como cockpit de gestão
2. **Segunda reclassificação (2026-04-16):** Substituição completa do Hermes Agent pelo Cindy Agent

O Hermes Agent foi descontinuado:
- **WSL2 Ubuntu:** Instalação quebrada, removida
- **Linux Server:** Formatado/removido

**Novo baseline operacional:** Cindy Agent 2026.4.14 no WSL2 Ubuntu

---

## Escopo
### Fase 1 — Migração do Runtime
- Instalação do Cindy Agent 2026.4.14 no WSL2 Ubuntu
- Remoção do Hermes Agent quebrado
- Configuração inicial de credenciais

### Fase 2 — Configuração de Segurança
- Configuração de gateway token auth
- Security audit aplicado (0 critical, 1 warn)
- Bind LAN configurado para acesso via rede

### Fase 3 — Operacionalização
- Gateway rodando em porta 18789
- Telegram @Sentivis_bot conectado e aprovado
- Control Panel acessível via LAN

### Fase 4 — Treinamento Cindy Agent (Nova)
- Explorar capabilities e commands do Cindy Agent
- Testar tools e agents disponíveis
- Documentar capabilities descobertas
- Identificar integrações úteis para o projeto

---

## Backlog

| ID | Estória | SP | Dependência | Status |
|---|---|---|---|---|
| ST-S4-01 | Definir papel do Discord, categorias, canais e contrato Discord -> ACP | 5 | — | Done |
| ST-S4-02 | Estruturar servidor Discord com roles, threads e comandos mínimos | 8 | ST-S4-01 | Done |
| ST-S4-03 | Materializar Cindy/Bot no Discord com comandos de status, tarefa e review | 5 | ST-S4-02 | Done |
| ST-S4-04 | Integrar bridge Discord -> Cindy -> ACP/Redis e retorno de status | 8 | ST-S4-03 | Done |
| ST-S4-05 | Refletir eventos relevantes em Dev_Tracking, bugs_log e templates operacionais | 5 | ST-S4-04 | Done |
| ST-S4-06 | Instalar Cindy Agent 2026.4.14 no WSL2 Ubuntu | 8 | — | Done |
| ST-S4-07 | Configurar MiniMax API Key no Cindy Agent | 3 | ST-S4-06 | Done |
| ST-S4-08 | Configurar Telegram bot token no Cindy Agent | 3 | ST-S4-06 | Done |
| ST-S4-09 | Configurar Gateway token auth | 5 | ST-S4-06 | Done |
| ST-S4-10 | Configurar acesso LAN (bind=lan) | 3 | ST-S4-06 | Done |
| ST-S4-11 | Aprovar pairing Telegram e validar conexão | 3 | ST-S4-08 | Done |

---

## Decisões
| ID | Descrição | Data |
|---|---|---|
| D-S4-01 | S4 reclassificada pelo PO para focar na implantação e validação operacional do Discord | 2026-04-15 |
| D-S4-02 | O backlog técnico anterior de Microsoft Agent Framework, SonarCloud e observabilidade passa para S5 | 2026-04-15 |
| D-S4-03 | Credenciais do Discord validadas; comandos slash registrados globalmente; instalação em guild ainda pendente | 2026-04-15 |
| D-S4-04 | `DISCORD_GUILD_ID` configurado no env; teste de API retornou `403` para comandos do guild | 2026-04-15 |
| D-S4-05 | Catálogo do guild realinhado ao runtime Hermes atual | 2026-04-15 |
| D-S4-06 | Aceite técnico parcial: `/help` e `/clear` validados no Discord; `/status` pendente | 2026-04-15 |
| D-S4-07 | Validação Playwright/Discord: login web concluído; autocomplete mínimo confirmado | 2026-04-15 |
| D-S4-08 | Auditoria tripla aprovada: Discord App, Runtime, Backlog | 2026-04-15 |
| D-S4-09 | MVP recortado: ST-S4-04 e ST-S4-05 adiados para S5 | 2026-04-15 |
| D-S4-10 | Pré-work ST-S4-01 concluído: dead code removido | 2026-04-15 |
| D-S4-11 | DISCORD_COCKPIT_DEFINITION.md produzido | 2026-04-15 |
| D-S4-12 | DISCORD_SERVER_SETUP.md criado | 2026-04-15 |
| D-S4-13 | 7 handlers de cockpit implementados | 2026-04-15 |
| D-S4-14 | **Cindy Agent 2026.4.14 instalado no WSL2 Ubuntu** substituindo Hermes Agent. Hermes do Linux server foi formatado/removido | 2026-04-16 |
| D-S4-15 | **Credenciais configuradas:** MiniMax API Key, Telegram Bot Token, Gateway Token - todas salvas em `.scr\.env` | 2026-04-16 |
| D-S4-16 | **Gateway LAN configurado:** bind=lan, porta 18789, acessível em `http://192.168.15.4:18789/` | 2026-04-16 |
| D-S4-17 | **Telegram aprovado:** pairing code ZSJHWGJS aprovado para user 8687754084 | 2026-04-16 |
| D-S4-18 | **Modelo MiniMax-M2.7 configurado** como default agent model | 2026-04-16 |

---

## Timestamp UTC
| Event | Start | Finish | Status |
|---|---|---|---|
| Kickoff S4 | 2026-04-15T00:00:00Z | — | Done |
| Discord app setup | 2026-04-15T13:33:22Z | 2026-04-15T13:33:22Z | Done |
| Realinhamento do catálogo | 2026-04-15T18:24:01Z | 2026-04-15T18:24:01Z | Done |
| Cindy Agent install start | 2026-04-16T00:32:00Z | 2026-04-16T00:34:00Z | Done |
| Cindy Agent setup | 2026-04-16T00:56:00Z | 2026-04-16T01:08:00Z | Done |
| Gateway token config | 2026-04-16T03:08:00Z | 2026-04-16T03:09:00Z | Done |
| Telegram pairing approved | 2026-04-16T03:16:00Z | 2026-04-16T03:16:00Z | Done |
| LAN bind configured | 2026-04-16T03:47:00Z | 2026-04-16T03:48:00Z | Done |
| S4 | 2026-04-15T00:00:00Z | — | Mantida aberta |

---

## Estado Final - Cindy Agent

### Configuração Ativa
| Componente | Valor |
|------------|-------|
| Versão | Cindy Agent 2026.4.14 (323493f) |
| Host | WSL2 Ubuntu (SentivisIA) |
| Gateway | ws://127.0.0.1:18789 |
| LAN | http://192.168.15.4:18789 |
| Modelo | Runtime atual da Cindy Agent |
| Bind | LAN (0.0.0.0) |

### Credenciais (`.scr\.env`)
As credenciais permanecem apenas em `.scr/.env` e nao sao reproduzidas aqui.

### Scripts Criados
| Script | Função |
|--------|---------|
| Script de inicialização do gateway da Cindy Agent | Iniciar gateway |
| Setup interativo da Cindy Agent | Preparar ambiente |
| Informações de credenciais da Cindy Agent | Ver credenciais |
| Informações de conexão da Cindy Agent | Dados de conexão |

### Security Audit
- CRITICAL: 0
- WARN: 1 (trusted proxies - OK para uso local)

---

## Notas Técnicas
- **Cindy Agent:** baseline operacional atual
- **Discord:** permanece no Hermes (não migrado para Cindy Agent nesta sprint)
- **Telegram:** configurado no Cindy Agent
- **Gateway:** acessível via LAN para dispositivos na rede

## Próximos Passos (S5)
- Migrar Discord do Hermes para Cindy Agent
- Configurar WhatsApp
- Explorar capabilities de agents e tools

## Situação Atual
- Sprint S4 permanece aberta por decisão do PO
- O trabalho em curso continua sendo referência ativa para o time e para a documentação canônica

---

## Referências
- `tests/bugs_log.md` - TEST-S5-01
- `Dev_Tracking_S5.md` - Sprint seguinte
- `Dev_Tracking.md` - Índice de sprints
