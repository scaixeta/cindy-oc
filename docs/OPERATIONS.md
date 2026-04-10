# OPERATIONS.md — Operações

## Visão Geral

Guia operacional para Cindy Agent em produção.

## Hermes CLI

### Comandos Principais

```powershell
hermes --version          # Verificar versão
hermes status             # Status do sistema
hermes connect telegram    # Conectar Telegram
hermes disconnect          # Desconectar
```

### Gerenciamento de Agentes

```powershell
hermes agents list        # Listar agentes
hermes agents start       # Iniciar agente
hermes agents stop        # Parar agente
```

## Telegram

### Verificar Conectividade

Bot deve responder a `/start` quando configurado.

### Logs

Verificar logs de conexão em caso de falhas.

## Monitoramento

| Métrica | Como Verificar |
|---------|----------------|
| Status do Hermes | `hermes status` |
| Conectividade Telegram | Testar bot |
| Logs de erro | Output do Hermes CLI |

## Troubleshooting

| Problema | Solução |
|----------|---------|
| Bot não responde | Verificar token e conexão |
| Hermes não inicia | Verificar instalação e dependências |
| Workspace não encontrado | Verificar caminho `C:\cindyagent` |

## Manutenção

### Backup

Manter backup dos artefatos canônicos:

- `Dev_Tracking*.md`
- `Cindy_Contract.md`
- `rules/WORKSPACE_RULES.md`

### Atualização

Para atualizar:

1. Parar Hermes
2. Atualizar via npm
3. Validar configuração
4. Reiniciar

## Procedimentos de Emergência

| Situação | Ação |
|----------|------|
| Bot para de responder | Verificar token, reconnect |
| Perda de contexto | Consultar Dev_Tracking_SX.md |
| Erro de governança | Reler rules/WORKSPACE_RULES.md |

## Contatos

| Papel | Responsável |
|-------|-------------|
| PO | Pendente de validação |

## Referência

Consulte [SETUP.md](SETUP.md) para configuração inicial.
