# SETUP

## Proposito

Este documento descreve como preparar o contexto minimo para trabalhar no `Cindy OC` em ambiente Windows, com foco em operacao local-first no `VS Code`.

## 1. Contexto do repositorio

- Projeto: `Cindy OC`
- Fase atual: `OpenClaw Fase 1 - Instalacao, confirmacao, configuracao e lockdown`
- Sprint ativa: `S2`
- Escopo aprovado: `Instalacao OpenClaw, confirmacao runtime, configuracao controlada, lockdown`
- Tipo de repositorio: `Projeto derivado da Cindy para operacao local`

## 2. Requisitos minimos

- Git
- PowerShell
- VS Code

## 3. Estrutura minima esperada

```text
Cindy-OC/
├── README.md
├── Cindy_Contract.md
├── Dev_Tracking.md
├── Dev_Tracking_S2.md
├── docs/
│   ├── SETUP.md
│   ├── ARCHITECTURE.md
│   ├── DEVELOPMENT.md
│   └── OPERATIONS.md
├── rules/
├── tests/
├── Templates/
├── Sprint/
└── ...
```

## 4. Fontes de evidencia atuais

### 4.1 Evidencias ja disponiveis

- `README.md`
- `rules/WORKSPACE_RULES.md`
- `Cindy_Contract.md`
- `Dev_Tracking.md`
- `Dev_Tracking_S2.md`

### 4.2 Infraestrutura validada

- Railway - ativo
- n8n-runtime - ativo
- Postgres - saudavel
- Telegram MVP - operacional com dispatcher

## 5. Configuracoes locais

- Operacao local-first no `VS Code`
- `Codex` e `Cline` sao os agentes locais esperados
- `OpenClaw` Fase 1: em preparacao para instalacao e lockdown
- Fase anterior S1 validada: Telegram MVP, dispatcher, testes E2E 6/6

## 6. Limites do setup

- O setup atual cobre `infraestrutura validada (Railway, n8n, Postgres, Telegram) e OpenClaw Fase 1`
- O setup atual inclui `instalacao OpenClaw` (S2)
- O setup atual NAO inclui `funcionalidades OpenClaw` (ate Fase 1 validada)
- O setup atual NAO inclui `expansao de permissoes` (lockdown por padrao)

## 7. O que ainda nao esta configurado

- `OpenClaw` - Fase 1 em execucao (ST-S2-01 a ST-S2-08)
- `Funcionalidades OpenClaw` - Apenas lockdown e baseline controlados
- `Expansao de superficie` - Bloqueado por padrao ate validacao

## 8. Proximos passos

- Abrir `C:\Cindy-OC` no `VS Code`
- Ler `docs/ARCHITECTURE.md`
- Ler `docs/DEVELOPMENT.md`
- Ler `docs/OPERATIONS.md`
- Executar ST-S2-01: Preparar workspace e pre-requisitos para OpenClaw

