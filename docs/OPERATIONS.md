# OPERATIONS.md — Operacoes

## Visao Geral

Este documento descreve a operacao atual do Cindy Agent com Hermes em WSL, Telegram como canal principal, Discord em validacao como cockpit secundario, `hermes-gateway.service` como servico operacional real no Linux e OpenCode CLI como tool de delegacao.

## Estado operacional atual

| Item | Estado |
|---|---|
| Runtime Hermes | instalado e funcional |
| Local do runtime | `/root/.hermes` |
| Executavel | `/root/.hermes/hermes-agent/venv/bin/hermes` |
| Versao do Hermes Agent | `v0.9.0 (2026.4.13)` |
| Modelo primario do runtime | `MiniMax-M2.7` via `minimax` |
| Fallback do runtime | `gpt-5.3-codex` via `openai-codex` |
| Telegram | configurado e pareado |
| Discord | credenciais validadas na API; guild de teste ainda nao acessivel |
| Gateway | funcional via `hermes-gateway.service` |
| OpenCode | integrado via wrapper |
| Servico persistente | instalado e ativo no systemd de sistema |

## Comandos principais

### No Windows

```powershell
# Subir Hermes + Cindy no Telegram
.\start_hermes_cindy_telegram.bat

# Usar OpenCode (raciocinio profundo)
.\run_opencode.bat "pergunta aqui"
```

### No WSL / Hermes

```powershell
wsl -d Ubuntu --user root -- /root/.hermes/hermes-agent/venv/bin/hermes status
wsl -d Ubuntu --user root -- /root/.hermes/hermes-agent/venv/bin/hermes --version
wsl -d Ubuntu --user root -- /root/.hermes/hermes-agent/venv/bin/hermes gateway status
wsl -d Ubuntu --user root -- systemctl status hermes-gateway.service --no-pager
wsl -d Ubuntu --user root -- systemctl restart hermes-gateway.service
wsl -d Ubuntu --user root -- curl -s http://127.0.0.1:8642/health
wsl -d Ubuntu --user root -- /root/.hermes/hermes-agent/venv/bin/hermes chat -Q --source tool -q "Responda apenas OK"
```

## Semantica operacional da Cindy

- **Canal principal:** Telegram, quando o gateway esta ativo
- **Discord:** cockpit em implantacao; app validado na API, mas sem operacao de guild ainda
- **`acorde`:** retomada logica da sessao/contexto
- **Nao significa:** ligar maquina, acordar WSL ou iniciar Hermes do zero automaticamente
- **Commit/push:** somente com autorizacao explicita do PO
- **Selecao de reasoning engine:** tarefas simples e rapidas usam OpenCode (MiniMax M2.7); tarefas complexas de planejamento e arquitetura usam Codex
- **OpenCode:** tool de delegacao — usado para raciocinio profundo em codigo, nao substitui o Hermes

## Procedimento padrao de subida

1. garantir que `/root/.hermes/config.yaml` mantenha `MiniMax-M2.7` como primario e `gpt-5.3-codex` como fallback
2. reiniciar ou validar o `hermes-gateway.service`
3. validar `/health` e um `hermes chat -Q` curto
4. ativar ou reaplicar a persona Cindy no runtime vivo quando necessario
5. operar pelo Telegram ou CLI conforme disponibilidade

## Monitoramento rápido

| Verificação | Comando |
|---|---|
| Status geral do Hermes | `hermes status` |
| Versao do Hermes | `hermes --version` |
| Status do gateway | `hermes gateway status` |
| Status do servico real | `systemctl status hermes-gateway.service --no-pager` |
| Reinicio do servico real | `systemctl restart hermes-gateway.service` |
| Healthcheck local | `curl -s http://127.0.0.1:8642/health` |
| Teste rápido do OpenCode | `cd /d C:\cindyagent && opencode run --model minimax/MiniMax-M2.7 "echo hello"` |
| Teste ACP (multi-agente) | `python3 .agents/scripts/test_acp_multi_agent.py` |
| Keys ACP no Redis | `redis-cli KEYS "acp:*"` |
| Stream de um agente | `redis-cli XLEN acp:stream:sentivis` |

## Troubleshooting actual

| Problema | Causa provavel | Correcao minima |
|---|---|---|
| Telegram nao responde | gateway parado ou config desatualizada no reboot | validar `/root/.hermes/config.yaml`, reiniciar `hermes-gateway.service` e testar `/health` |
| `hermes status` mostra `Gateway Service: stopped` | status do `systemd (user)` e nao do servico real | conferir `systemctl status hermes-gateway.service --no-pager` |
| Update do Hermes encontra mudanca local no repo | risco de sobrescrever ajuste operacional | gerar patch de backup, aplicar `git stash` e so depois atualizar |
| OpenCode retorna "invalid api key" | MINIMAX_API_KEY expirada ou invalida | verificar chave em `.scr/.env` |
| Discord retorna 403 ao registrar comandos no guild | bot ainda nao instalado ou autorizado no servidor | instalar o app no guild de teste e repetir o registro |
| Warnings de `.env` no WSL | arquivo com `CRLF` | normalizar para `LF` |
| Caracteres quebrados no terminal Windows | encoding do console | usar terminal UTF-8 / PowerShell com code page adequada |

## Operacao como servico

O modo operacional real validado neste projeto e o servico de sistema `hermes-gateway.service`.

Comandos disponiveis:

```powershell
wsl -d Ubuntu --user root -- systemctl status hermes-gateway.service --no-pager
wsl -d Ubuntu --user root -- systemctl restart hermes-gateway.service
wsl -d Ubuntu --user root -- /root/.hermes/hermes-agent/venv/bin/hermes gateway install
wsl -d Ubuntu --user root -- /root/.hermes/hermes-agent/venv/bin/hermes gateway uninstall
```

## Operações da equipe de agentes

### Enviar tarefa via ACP
```python
python3 -c "
import sys
sys.path.insert(0, '.agents/scripts')
from acp_redis import ACPRedis
acp = ACPRedis()
acp.publish(to='sentivis', msg_type='TASK', action='check_device_status', payload={'device':'NIMBUS-AERO'}, from_agent='cindy')
print('Tarefa enviada')
"
```

### Gate de classificação (5 agentes)
```bash
python .agents/skills/dual-model-orchestrator/scripts/dual_model_gate.py "monitorar thingsboard"
# Retorna: SENTIVIS
```

## Limite de iteração

- 3-5 ciclos Discussão→Execução→Validação
- Após limite: escalar para PO via Cindy

## Referências da equipe

- `docs/AGENT_TEAM_MODEL.md` — modelo operacional
- `docs/ACP_PROTO.md` — especificação ACP
- `docs/SETUP.md` — configuração do ambiente
