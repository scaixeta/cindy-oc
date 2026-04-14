# SETUP.md — Configuracao do Ambiente

## Visao Geral

O projeto opera sobre **Windows + WSL2 + Ubuntu + Hermes**, com Telegram como canal operacional principal, `hermes-gateway.service` como servico ativo no Linux e OpenCode CLI como tool de raciocinio profundo.

## Ambiente atual confirmado

| Item | Estado atual |
|---|---|
| Sistema operacional host | Windows 11 |
| Subsistema Linux | WSL2 |
| Distro principal | Ubuntu |
| Workspace Windows | `C:\CindyAgent` |
| Workspace em WSL | `/mnt/c/CindyAgent` |
| Runtime Hermes vivo | `/root/.hermes` |
| Servico do gateway | `hermes-gateway.service` (systemd de sistema) |
| Estado do gateway | `active (running)` |
| Modelo Hermes primario | `MiniMax-M2.7` via `minimax` |
| Fallback Hermes | `gpt-5.3-codex` via `openai-codex` |
| OpenCode CLI | `run_opencode.bat` (wrapper) |
| Modelo OpenCode | `minimax/MiniMax-M2.7` |

## Pré-requisitos operacionais

- Windows com WSL2 funcional
- distro Ubuntu instalada
- Hermes instalado dentro do WSL
- credenciais do Telegram já configuradas no runtime Hermes
- MINIMAX_API_KEY do Coding Plan em `.scr/.env` (nunca versionar)
- OpenCode CLI acessível via `run_opencode.bat`
- Redis 7.0+ rodando em `localhost:6379` (já instalado no ambiente)

## Equipe de 5 Agentes

| Agente | Modelo | Escopo |
|---|---|---|
| Cindy | MiniMax-M2.7 | Coordenadora/PM |
| Sentivis | GLM-5.1:cloud | IoT & Infra (ThingsBoard, n8n, Cirrus Lab) |
| MiniMax | MiniMax-M2.7 | AI & Logic (código) |
| Scribe | GLM-5.1:cloud | Docs & Integration |
| GLM-5.1 | GLM-5.1:cloud | Senior Validator/QA |

Comunicação via ACP/Redis — `.agents/scripts/acp_redis.py`.

## Estrutura relevante do runtime Hermes

```
/root/.hermes/
├── SOUL.md
├── memories/
│   ├── USER.md
│   └── MEMORY.md
├── config.yaml
├── .env
└── hermes-agent/
    └── venv/bin/hermes
```

## KB canonica da Cindy neste repositorio

```
KB/hermes/
├── README.md
├── SOUL.md
├── USER.md
└── MEMORY.md
```

Essa KB e a origem canonica para a persona da Cindy no Hermes. O runtime vivo em `/root/.hermes` deve permanecer coerente com esse conteudo.

## Inicializacao pratica

### Subir Hermes + Cindy no Telegram

```powershell
.\start_hermes_cindy_telegram.bat
```

Esse launcher:
1. tenta reiniciar o gateway do Hermes pelo bootstrap Windows atual
2. reativa a persona Cindy no runtime
3. mostra o status do gateway

Observacao importante: o servico operacional validado em producao local e o `hermes-gateway.service` no systemd de sistema. O bootstrap Windows ainda precisa ser endurecido para ficar totalmente alinhado a esse modo persistente.

### Usar OpenCode para raciocinio profundo

```batch
.\run_opencode.bat "prompt aqui"
```

O wrapper le `MINIMAX_API_KEY` do `.scr/.env` e passa ao OpenCode via PowerShell (resolve problema de scoping do `set` no cmd.exe).

## Validacao minima do ambiente

```powershell
wsl -d Ubuntu --user root -- /root/.hermes/hermes-agent/venv/bin/hermes status
wsl -d Ubuntu --user root -- /root/.hermes/hermes-agent/venv/bin/hermes gateway status
wsl -d Ubuntu --user root -- systemctl status hermes-gateway.service --no-pager
wsl -d Ubuntu --user root -- curl -s http://127.0.0.1:8642/health
wsl -d Ubuntu --user root -- /root/.hermes/hermes-agent/venv/bin/hermes chat -Q --source tool -q "Responda apenas OK"
```

## Regras importantes de setup

- `.scr/.env` e segredo local e nao deve ser versionado
- o runtime atual do Hermes esta vinculado ao usuario `root` no WSL
- Telegram e canal principal **somente** quando o gateway esta ativo
- `acorde` deve ser interpretado como retomada logica, nao wake da maquina
- OpenCode e tool de delegacao — nao substitui o Hermes

## Pendencias conhecidas

| Item | Status |
|---|---|
| Bootstrap Windows ainda nao alinhado ao servico systemd persistente | Pendente |
| Aviso de `Gateway Service: stopped` no `hermes status` (`systemd user`) | Conhecido / benigno |
| Replicacao para outros projetos da Cindy | Planejada (ST-S1-16) |
| GSD (Get Shit Done) | Nao faz parte deste projeto |

## Referências da equipe

- `docs/AGENT_TEAM_MODEL.md` — modelo operacional da equipe de 5 agentes
- `docs/ACP_PROTO.md` — especificação do protocolo ACP
- `docs/ARCHITECTURE.md` — arquitetura completa do sistema
- `rules/WORKSPACE_RULES.md` — Regra 27 (orquestração)
- `.agents/skills/dual-model-orchestrator/SKILL.md` — skill de orquestração
