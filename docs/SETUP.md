# SETUP

## Proposito

Este documento descreve como preparar o contexto minimo para trabalhar no `Cindy OC` em ambiente Windows, com foco em operacao local-first no `VS Code`.

## 1. Contexto do repositorio

- Projeto: `Cindy OC`
- Fase atual: `Bootstrap local`
- Sprint ativa: `S0`
- Escopo aprovado: `Estrutura canonica, baseline minimo da Cindy e preparacao para evolucao local`
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
├── Dev_Tracking_S0.md
├── docs/
│   ├── SETUP.md
│   ├── ARCHITECTURE.md
│   ├── DEVELOPMENT.md
│   └── OPERATIONS.md
├── rules/
├── tests/
├── Templates/
├── .agents/
├── .cline/
├── .clinerules/
├── .codex/
└── Sprint/
```

## 4. Fontes de evidencia atuais

### 4.1 Evidencias ja disponiveis

- `README.md`
- `rules/WORKSPACE_RULES.md`
- `Cindy_Contract.md`

### 4.2 Classificacao inicial das evidencias

- Confirmado: `Projeto local em C:\Cindy-OC com sprint S0 ativa`
- Inferido: `Railway sera avaliado como camada futura de servicos`
- Pendente de validacao: `Integracoes reais com OpenClaw, Slack, n8n e ThingsBoard`

### 4.3 Preservacao de evidencia

- Nao apagar arquivos de evidencia existentes sem justificativa explicita
- Nao sobrescrever conteudo do usuario sem necessidade comprovada
- Tratar docs canonicos e tracking como fontes primarias do projeto

## 5. Conferir a trilha canonica

Exemplos Windows (PowerShell):

```powershell
Set-Location C:\Cindy-OC
Get-ChildItem
Get-ChildItem docs
Get-ChildItem rules
Get-ChildItem tests
```

Arquivos minimos esperados:

- `README.md`
- `Cindy_Contract.md`
- `Dev_Tracking.md`
- `Dev_Tracking_S0.md`
- `tests/bugs_log.md`
- `rules/WORKSPACE_RULES.md`

## 6. Leitura minima antes de agir

1. `rules/WORKSPACE_RULES.md`
2. regra global do runtime ativo
3. `Cindy_Contract.md`
4. `README.md`
5. `Dev_Tracking.md`
6. `Dev_Tracking_S0.md`
7. apenas os docs canonicos necessarios

## 7. Configuracoes locais

- Operacao local-first no `VS Code`
- `Codex` e `Cline` sao os agentes locais esperados
- `OpenClaw` e camada externa futura, opcional e nao configurada agora
- Nao presumir `.env`, tokens, webhooks, VPS, servicos Railway ou integracoes reais nesta fase

## 8. Limites atuais do setup

- O setup atual cobre apenas `estrutura local, documentacao e baseline minimo`
- O setup atual nao inclui `deploy`
- O setup atual nao inclui `provisionamento Railway`
- O setup atual nao inclui `wiring real com OpenClaw ou Slack`

## 9. O que ainda nao esta configurado

- `Projeto Railway e servicos reais`
- `Instancia real de n8n ou ThingsBoard`
- `Fluxo operacional externo com OpenClaw`

## 10. Proximos passos

- Abrir `C:\Cindy-OC` no `VS Code`
- Ler `docs/ARCHITECTURE.md`
- Ler `docs/DEVELOPMENT.md`
- Ler `docs/OPERATIONS.md`
