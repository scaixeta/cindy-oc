# Runtime Export do Hermes

## Geração

- Gerado em: `2026-04-14T17:30:16-03:00` **(atualizado após correção do runtime Linux e validação do gateway)**
- Origem: `/root/.hermes`
- Destino: `KB/hermes/` e `KB/hermes/runtime_export/`
- Política: segredos e credenciais redigidos; `auth.json`, bancos e tokens não foram exportados

## Memórias sincronizadas

- `SOUL.md` sincronizado do runtime vivo
- `USER.md` sincronizado do runtime vivo
- `MEMORY.md` sincronizado do runtime vivo

## Estado atual do runtime

| Campo | Valor |
|---|---|
| Modelo padrão | `MiniMax-M2.7` |
| Provider padrão | `minimax` |
| Fallback provider | `openai-codex` |
| Fallback model | `gpt-5.3-codex` |
| Fallback base_url | `https://chatgpt.com/backend-api/codex` |
| Personalidade de display | `technical` |
| Voz TTS Edge | `pt-BR-FranciscaNeural` |
| API server habilitado | `true` |
| Endpoint local de saúde | `http://127.0.0.1:8642/health` |
| Endpoint OpenAI compatível | `http://127.0.0.1:8642/v1` |
| WebUI local validada | `http://127.0.0.1:9119` |
| Telegram no gateway | `connected` |
| API server no gateway | `connected` |
| Usuário Telegram permitido | `8687754084` |

## Artefatos exportados

- `runtime_export/config.runtime.yaml`
- `runtime_export/env.runtime.redacted`
- `runtime_export/gateway_state.runtime.json`
- `runtime_export/channel_directory.runtime.json`
- `runtime_export/status.runtime.txt`
- `runtime_export/doctor.runtime.txt`

## Observações operacionais

- O `hermes status` exportado deve mostrar o modelo principal como `MiniMax-M2.7` via `MiniMax`.
- O `fallback_model` canônico deve permanecer como `gpt-5.3-codex` via `openai-codex` com `base_url: https://chatgpt.com/backend-api/codex`.
- O `hermes-gateway.service` (systemd de sistema) está `active (running)`.
- A WebUI local foi validada por `hermes dashboard` em `http://127.0.0.1:9119`; isso complementa, mas não substitui, o acompanhamento da S4.
- O `hermes status` pode mostrar "stopped" no manager `systemd (user)` para o gateway, mas o serviço real em uso é o systemd de sistema, que está ativo.
- O runtime opera simultaneamente com `telegram` e `api_server` no gateway.
- O `.env` exportado foi redigido; somente chaves não sensíveis de configuração operacional foram preservadas em claro.
- O `config.yaml` exportado reflete o estado vivo atual, incluindo `display.personality: technical`, voz `pt-BR-FranciscaNeural`, `MiniMax-M2.7` como primário e `gpt-5.3-codex` como fallback.
- O status do `doctor` continua apontando ausências opcionais do ecossistema, como chaves de `web`, dependências de `homeassistant`, `image_gen`, `rl` e o submódulo `tinker-atropos`.
- O snapshot Hermes ainda pode mostrar `Discord ✗ not configured`; a superfície Discord MVP é mantida e validada separadamente em `KB/aiops/Discord_Operating_Model.md` e no tracking S4.
- O caminho oficial para WebUI é `hermes dashboard` ou um cliente Open WebUI apontando para o API server do Hermes.
- O caminho oficial para operação paralela tipo “Swarm” é `hermes profile` + `--profile` + `--worktree`.
