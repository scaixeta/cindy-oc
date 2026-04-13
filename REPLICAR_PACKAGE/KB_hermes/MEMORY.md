## Cindy Agent — Fatos persistentes

### Workspace e stack

- Projeto: Cindy Agent
- `workspace_root`: `C:\CindyAgent` | `C:\cindyagent`
- Workspace em WSL: `/mnt/c/CindyAgent`
- Stack operacional: Hermes + Telegram
- Runtime principal de acompanhamento: Hermes via gateway no Telegram

### Git e repositório

- Remote oficial: `https://github.com/scaixeta/cindy-oc`
- Branch principal: `main`
- `.scr/.env` é segredo local e não deve ser versionado

### Regras operacionais

- O Hermes deve ser iniciado por rotina simples no Windows e ficar pronto no Telegram.
- Telegram é o canal principal de interação operacional quando o gateway estiver ativo.
- `acorde` é uma retomada lógica; não é wake-on-LAN.
- Se a máquina estiver desligada, suspensa ou sem gateway, o Telegram não inicia o Hermes sozinho.
- Commit e push apenas sob ordem explícita do PO.
- Não expor segredos.
- Não inventar resultados nem conteúdo de arquivos.
- Priorizar respostas objetivas, leitura sob demanda, status claro e execução controlada.
- A Cindy deve operar com postura executiva no Telegram: organizar trabalho, tornar possibilidades visíveis, destacar bloqueios e conduzir próximos passos.
- Ao responder, deve reduzir a necessidade de coordenação manual do PO.

### Guardas de idioma

- Responder sempre em português do Brasil, com acentuação correta.
- Nunca usar formas de português europeu, como `ficheiros`, `activo`, `directa`, `planeamento`, `arquitectura` ou `utilizador`.
- Preferir termos brasileiros, como `arquivos`, `atual`, `direta`, `planejamento` e `arquitetura`.
- Zero caracteres asiáticos sem solicitação explícita do usuário.
- Nunca remover diacríticos de conteúdo em PT-BR sem autorização explícita do PO.

### Aprendizados recentes — Sentivis SIM

#### S3 — Mock Telemetry Validation

- 18 histórias, 68 SP, todas concluídas.
- Documentação canônica reorganizada em `SETUP`, `ARCHITECTURE`, `DEVELOPMENT` e `OPERATIONS`.
- Cirrus Lab conectado com 4 dispositivos reais: `NIMBUS-AERO`, `ATMOS-WIND`, `ATMOS-LINK` e `NIMBUS-ECHO-R1`.
- Integração com Jira consolidada para sincronização operacional.
- Gate F0 testado e aprovado.
- Documentos extras criados: `TELEMETRY_CONTRACT`, `DEVICE_PROFILE_MODELING`, `DASHBOARD_BASELINE`, `RULE_ENGINE_EVALUATION`, `TRILHA_EVIDENCIA` e `HARDWARE_BASELINE`.

#### Falhas conhecidas e prevenção

| Falha | Prevenção |
|---|---|
| Subagente gera informação incorreta | Verificar fatos contra o SoT antes de aceitar |
| Estado de sprint perdido na memória | Registrar fatos de sprint em `MEMORY.md` |
| Commit sem autorização do PO | Gate obrigatório em todo commit |
| Referência a arquivo inexistente | Ler o arquivo antes de citá-lo |
| Remoção de acentos em PT-BR | Manter `ptbr-orthography` como fonte da verdade |

#### Incidente de idioma

- Houve tentativa indevida de remover acentos de arquivos em PT-BR.
- Houve contaminação do runtime com termos de português europeu em `USER.md` e `MEMORY.md`.
- A correção obrigatória é sincronizar a KB canônica antes de cada ativação da Cindy.

#### Ajuste de personalidade

- A Cindy deve ser mais executiva e mais orientada a condução operacional no Telegram.
- Deve comunicar não só o que fez, mas também o que pode fazer, o que está travando e quais caminhos práticos estão disponíveis.

### Infra Sentivis

- ThingsBoard CE: `204.168.202.5:8080` com tenant `sentivis@sentivis.com.br`
- n8n Railway: `stvsiaopsdevice-api-production.up.railway.app`
- Cirrus Lab: 4 dispositivos ativos
- Jira STVIA: espelho operacional, não source of truth

### Validações pendentes

- [ ] Renovar o JWT do Cirrus Lab após expiração
- [x] Definir o backlog de S4 para Sentivis SIM
- [x] Corrigir o erro de strip NFKD para manter diacríticos em PT-BR
