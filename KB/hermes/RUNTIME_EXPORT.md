# Runtime Export do Hermes

## Geração

- Gerado em: `2026-04-11T10:53:43-03:00`
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
| Personalidade de display | `technical` |
| Voz TTS Edge | `pt-BR-FranciscaNeural` |
| API server habilitado | `true` |
| Endpoint local de saúde | `http://127.0.0.1:8642/health` |
| Endpoint OpenAI compatível | `http://127.0.0.1:8642/v1` |
| Telegram no gateway | `connected` |
| API server no gateway | `connected` |
| Usuário Telegram permitido | `8687754084` |
| Total de arquivos em `/root/.hermes/sessions` | `157` |

## Artefatos exportados

- `runtime_export/config.runtime.yaml`
- `runtime_export/env.runtime.redacted`
- `runtime_export/gateway_state.runtime.json`
- `runtime_export/channel_directory.runtime.json`
- `runtime_export/status.runtime.txt`
- `runtime_export/doctor.runtime.txt`

## Observações

- O runtime está operando simultaneamente com `telegram` e `api_server` no gateway.
- O `.env` exportado foi redigido; somente chaves não sensíveis de configuração operacional foram preservadas em claro.
- O `config.yaml` exportado reflete o estado vivo atual, incluindo `display.personality: technical` e voz `pt-BR-FranciscaNeural`.
- O status do `doctor` continua apontando ausências opcionais do ecossistema, como chaves de `web`, dependências de `homeassistant`, `image_gen`, `rl` e o submódulo `tinker-atropos`.
