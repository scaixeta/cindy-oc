# bugs_log.md — Log de Bugs, Testes e Evidências

## Sprint S3

### BUG-S3-04 — Bytecode envenenado (.pyc) recorrente após reboot — BUG-S3-03 reincidente

- **Data:** 2026-04-14
- **Severidade:** Alta
- **Evidência:** Após cada reboot do WSL2, o `hermes-gateway.service` subia com `Tasks: 1` e o journal mostrava `ImportError: cannot import name '_write_codex_cli_tokens' from 'hermes_cli.auth'` em todas as sessões Telegram. O Telegram recebia a mensagem mas o agente falhava ao processar — sem resposta ao usuário.
- **Causa raiz:** O Python regenera automaticamente arquivos `.pyc` no primeiro import após boot. Os arquivos `.pyc` do Hermes v0.8.0 eram recriados a cada início de serviço, pois a limpeza manual feita em BUG-S3-03 não persistia entre reboots.
- **Correção permanente:** Adicionado `ExecStartPre` de limpeza de `.pyc` e `__pycache__` diretamente no unit file `/etc/systemd/system/hermes-gateway.service`:
  ```
  ExecStartPre=/bin/bash -lc 'find /root/.hermes/hermes-agent -name *.pyc -delete; find /root/.hermes/hermes-agent -name __pycache__ -type d -exec rm -rf {} + 2>/dev/null; true'
  ```
- **Backup do unit file original:** `/etc/systemd/system/hermes-gateway.service.bak`
- **Validação:** Após `systemctl daemon-reload && systemctl start hermes-gateway.service`: `Tasks: 5`, healthcheck `{"status":"ok"}`, sem `ImportError` no journal. O `ExecStartPre` de limpeza aparece como `status=0/SUCCESS` no `systemctl status`.
- **Status:** Corrigido permanentemente

### TEST-S3-05 — Fix permanente de bytecode validado

- **Data:** 2026-04-14
- **Escopo:** Confirmar que o `ExecStartPre` de limpeza de `.pyc` no unit file do systemd elimina o `ImportError` de forma permanente, sem necessidade de intervenção manual após reboots.
- **Resultado:** `systemctl daemon-reload && systemctl start hermes-gateway.service` → Process 553 executou `find ... -delete` com `status=0/SUCCESS`; `Tasks: 5`; healthcheck `{"status":"ok","platform":"hermes-agent"}`; journal sem `ImportError`. Fix sobrevive a restarts automáticos (`Restart=always`).
- **Evidência:** `systemctl status hermes-gateway.service` mostra o novo `ExecStartPre` executado com sucesso em cada ciclo de start.
- **Status:** Passou

### BUG-S3-01 — Fallback MiniMax não ativava no contexto cron do Hermes

- **Data:** 2026-04-14
- **Severidade:** Alta
- **Evidência:** Log `gateway.log` mostra `fallback_model received: None` e `_fallback_chain populated: []` em todas as execuções cron. Fallback nunca disparava ao falhar primary `gpt-5.2-codex`.
- **Impacto:** Jobs cron falhavam com HTTP 400 quando primary indisponível, sem fallback automático para MiniMax-M2.7
- **Causa raiz dupla:**
  1. `fallback_providers: [minimax]` no config.yaml sobrescrevia `fallback_model` dict, populando chain com string inválida filtrada
  2. Cron scheduler (`cron/scheduler.py`) não passava `fallback_model` para o AIAgent
- **Correção:**
  - Removido `fallback_providers` do config.yaml
  - Adicionado `fallback_model=_cfg.get("fallback_model")` em `cron/scheduler.py` linha ~663
- **Validação:** Cron 16:20 confirmou `Fallback activated: gpt-5.2-codex → MiniMax-M2.7 (minimax)` e output de sucesso
- **Status:** Corrigido

### TEST-S3-01 — Fallback MiniMax ativado com sucesso no cron

- **Data:** 2026-04-14
- **Escopo:** Validar que o fallback MiniMax funciona no contexto cron após correção
- **Resultado:** `Fallback activated: gpt-5.2-codex → MiniMax-M2.7 (minimax)` confirmado no log. Cron output `2026-04-14_16-20-59.md` mostra Redis operante com sync executado
- **Evidência:** `KB/hermes/fallback_diagnosis.md` seção 10.2
- **Status:** Passou

### BUG-S3-02 — Reboot carregou configuração antiga do Hermes no runtime root

- **Data:** 2026-04-14
- **Severidade:** Alta
- **Evidência:** após reboot, o `hermes-gateway.service` subiu com `/root/.hermes/config.yaml` antigo, apontando para Codex como primário; o journal mostrava HTTP 400 e o Telegram ficou sem responder
- **Impacto:** indisponibilidade operacional da Cindy no Telegram até reaplicação manual da configuração canônica no Linux
- **Correção:** regravação do `/root/.hermes/config.yaml` com `MiniMax-M2.7` como primário e `gpt-5.3-codex` como fallback, sincronização da KB da Cindy e reinício do `hermes-gateway.service`
- **Status:** Corrigido

### TEST-S3-02 — Runtime Linux revalidado após correção do reboot

- **Data:** 2026-04-14
- **Escopo:** validar o runtime Hermes no Linux após correção da configuração primária e reinício do serviço
- **Resultado:** `systemctl status hermes-gateway.service` permaneceu `active (running)`; `curl http://127.0.0.1:8642/health` respondeu `{"status": "ok", "platform": "hermes-agent"}`; `hermes chat -Q --source tool -q "Responda apenas OK"` retornou `OK`
- **Evidência:** validação operacional executada no runtime Linux durante esta sessão
- **Status:** Passou

### BUG-S3-03 — Bytecode envenenado (.pyc) do Hermes v0.8.0 bloqueava sessão Telegram

- **Data:** 2026-04-14
- **Severidade:** Alta
- **Evidência:** journal do `hermes-gateway.service` mostrava `ImportError: cannot import name '_write_codex_cli_tokens' from 'hermes_cli.auth'` em cada tentativa de sessão Telegram (`agent:main:telegram:dm:*`); o healthcheck `/health` respondia OK, mas o agente falhava ao processar mensagens
- **Impacto:** mesmo após correção do `config.yaml`, sessões Telegram continuavam a falhar com erro de import interno
- **Causa raiz:** o diretório `__pycache__` e arquivos `.pyc` do Hermes v0.8.0 permaneceram no venv após update para v0.9.0; o bytecode compilado referenciava estruturas internas do `hermes_cli.auth` que não existiam na nova versão
- **Correção:** limpeza do bytecode obsoleto com `find /root/.hermes/hermes-agent -name '*.pyc' -delete && find /root/.hermes/hermes-agent -name '__pycache__' -type d -exec rm -rf {} +` seguida de `systemctl restart hermes-gateway.service`; após restart, journal limpo sem `ImportError` e sessão Telegram operante
- **Status:** Corrigido

### TEST-S3-04 — Sessão Telegram validada após limpeza de bytecode

- **Data:** 2026-04-14
- **Escopo:** confirmar que após limpeza de `__pycache__` e restart, o gateway processa sessões Telegram sem `ImportError`
- **Resultado:** `systemctl restart hermes-gateway.service` resulted in clean startup (journal sem `ImportError`); `curl http://127.0.0.1:8642/health` respondeu `{"status":"ok","platform":"hermes-agent"}`; `hermes gateway status` confirmou `active (running)` e service unit atual
- **Evidência:** journalctl confirmando startup limpo após restart
- **Status:** Passou

### TEST-S3-03 — Hermes atualizado para v0.9.0 com runtime preservado

- **Data:** 2026-04-14
- **Escopo:** atualizar o Hermes Agent de `v0.8.0` para `v0.9.0 (2026.4.13)` sem perder a alteração local existente em `cron/scheduler.py`
- **Resultado:** atualização concluída com sucesso; mudança local protegida por stash `pre-update-backup-2026-04-14` e patch `/root/.hermes/hermes-agent/.update-backup-cron-scheduler.patch`; `hermes --version` passou a mostrar `v0.9.0`; `hermes-gateway.service`, `/health` e `hermes chat -Q` permaneceram funcionais
- **Evidência:** validação operacional no runtime Linux após o update do Hermes
- **Status:** Passou

---

## Sprint S1

### BUG-S1-01 — Warnings no WSL ao ler `.scr/.env` com `CRLF`

- **Data:** 2026-04-09
- **Severidade:** Baixa
- **Evidência:** warnings do tipo `$'\r': command not found` durante ativação do runtime Hermes
- **Impacto:** ruído operacional no bootstrap da Cindy; sem impedir ativação
- **Correção:** normalização do `.scr/.env` local para `LF`
- **Status:** Corrigido

### TEST-S1-01 — Pairing Telegram aprovado

- **Data:** 2026-04-09
- **Escopo:** validar autorização do usuário no Telegram para uso do bot Hermes
- **Resultado:** pairing aprovado com sucesso; usuário reconhecido no próximo contato
- **Status:** Passou

### TEST-S1-02 — Gateway Hermes em execução manual

- **Data:** 2026-04-09
- **Escopo:** subir gateway Hermes e verificar operação fora de service manager
- **Resultado:** gateway em execução manual com PID ativo e status positivo
- **Status:** Passou

### TEST-S1-03 — Ativação da Cindy no runtime Hermes

- **Data:** 2026-04-09
- **Escopo:** enviar prompt de ativação usando `SOUL.md`, `USER.md` e `MEMORY.md` do runtime vivo
- **Resultado:** Cindy ativada com resposta válida e `session_id` gerado
- **Status:** Passou

### TEST-S1-04 — Proteção de `.scr/.env` no Git

- **Data:** 2026-04-09
- **Escopo:** validar remoção do segredo do histórico/versionamento e proteção por `.gitignore`
- **Resultado:** `.scr/.env` removido do histórico enviado ao remote e mantido apenas localmente
- **Status:** Passou

### TEST-S1-05 — API de testes FastAPI com `POST`/`GET`/`DELETE`

- **Data:** 2026-04-10
- **Escopo:** criar API de testes em FastAPI com endpoints `POST /registrar`, `GET /registros` e `DELETE /encerrar`; executar testes automatizados com `httpx.AsyncClient`; guardar evidência em `resultado_teste.json`
- **Resultado:** todos os testes passaram; 3 itens registrados, `GET` retornou 3 registros, `DELETE` devolveu relatório com contagem correta. Evidência guardada em `tests/test_api/resultado_teste.json`
- **Commit:** a8002d3
- **Status:** Passou

### TEST-S1-06 — Integração do Codex CLI

- **Data:** 2026-04-10
- **Escopo:** autenticar o Codex via `codex-cli auth login`, testar resposta do modelo com cálculo simples e configurar `gpt-5.2-codex` como modelo padrão para planejamento e arquitetura
- **Resultado:** autenticação via OAuth web (assinatura ChatGPT) confirmada; teste com `2+2` devolveu `4` com sucesso; modelo `gpt-5.2-codex` (`reasoning effort: high`, contexto: 400K) configurado como padrão para tarefas de planejamento e arquitetura
- **Status:** Passou

---

## Issues abertos

| ID | Descrição | Severidade | Status |
|---|---|---|---|
| ISSUE-S1-01 | Encoding do terminal Windows ainda pode exibir caracteres quebrados na saída do Hermes | Baixa | Aberto |

---

## Notas

- A sprint ativa atual é a `S4` (Discord)
- `Sprint/Dev_Tracking_S1.md` e `Sprint/Dev_Tracking_S2.md` preservam o histórico das sprints anteriores
- `Replicar.md` passa a ser tratado como mapa dos projetos principais da Cindy
- A replicação entre projetos ainda está em fase de planejamento e não foi executada neste ciclo
- `2026-04-11` — ST-S1-16: escopo Embrapa/café movido para Sentivis SIM (S5) — não pertence ao CindyAgent. Backlog do CindyAgent corrigido para 16 itens (ST-S1-16 renarrada como desalocação de escopo).

---

## Sprint S5

### TEST-S5-01 — Bateria de 5 reinicializações do Hermes Gateway validada

- **Data:** 2026-04-15
- **Escopo:** reiniciar o `hermes-gateway.service` cinco vezes, validar `systemctl is-active`, `gateway_state.json`, `curl /health` e `hermes chat -Q`
- **Resultado:** 5/5 ciclos concluídos com sucesso; o gateway final permaneceu `active (running)`, `telegram=connected`, `api_server=connected`, healthcheck respondeu `{"status":"ok","platform":"hermes-agent"}` e `hermes chat -Q --source tool -q "Responda apenas OK"` retornou `OK`
- **Observação:** o primeiro lote de reinicializações atingiu `start-limit-hit`; a unidade foi rearmada com `systemctl reset-failed hermes-gateway.service` e a bateria foi concluída com janela maior entre os ciclos
- **Evidência:** `systemctl status hermes-gateway.service --no-pager -l`, `/root/.hermes/gateway_state.json`, `curl http://127.0.0.1:8642/health`, `hermes chat -Q`
- **Status:** Passou

## Sprint S4

### TEST-S4-02 — Discord app validado e comandos slash registrados

- **Data:** 2026-04-15
- **Escopo:** confirmar conectividade do bot do Discord com a API, ajustar os install params do app para `bot + applications.commands` e registrar o conjunto mínimo de comandos slash
- **Resultado:** `GET /users/@me` retornou o bot esperado; `GET /applications/{app}/commands` mostrou a API disponível; `POST /applications/{app}/commands` e `PUT /applications/{app}/commands` registraram com sucesso o scaffold de comandos
- **Observação:** no momento desse teste ainda não havia `DISCORD_GUILD_ID` no env, então a instalação em guild permanecia pendente
- **Evidência:** `users/@me`, `applications/{app}`, `applications/{app}/commands`
- **Status:** Passou

### TEST-S4-03 — Guild Discord configurado, mas bot ainda não autorizado no servidor

- **Data:** 2026-04-15
- **Escopo:** validar a instalação efetiva do bot no guild configurado e registrar comandos no contexto do servidor
- **Resultado:** `DISCORD_GUILD_ID` está presente no env; `PUT /applications/{app}/guilds/{guild}/commands` retornou `403`; `GET /users/@me/guilds` não listou o guild alvo, indicando que o bot ainda não está autorizado/instalado no servidor
- **Evidência:** `DISCORD_GUILD_ID`, `users/@me/guilds`, `applications/{app}/guilds/{guild}/commands`
- **Status:** Bloqueado

### TEST-S4-04 — Discord instalado no guild e comandos do servidor registrados

- **Data:** 2026-04-15
- **Escopo:** confirmar que o bot está visível no guild de teste e que os comandos slash do escopo do servidor foram registrados
- **Resultado:** `GET /users/@me/guilds` retornou o guild `Cindy_Discord`; `PUT /applications/{app}/guilds/{guild}/commands` registrou `project`, `task`, `review`, `approve`, `incident`, `handoff` e `sprint` no guild
- **Evidência:** `users/@me/guilds`, `applications/{app}/guilds/{guild}/commands`
- **Status:** Passou

### TEST-S4-05 — Provisionamento de canais e roles bloqueado por permissões insuficientes

- **Data:** 2026-04-15
- **Escopo:** criar as categorias, canais e roles previstos para o cockpit Discord
- **Resultado:** a API retornou `Missing Permissions` ao tentar `POST /guilds/{guild}/channels` e `POST /guilds/{guild}/roles`; o bot não possui permissões suficientes para criar canais/roles no guild
- **Evidência:** `guilds/{guild}/channels`, `guilds/{guild}/roles`
- **Status:** Bloqueado

### TEST-S4-06 — Revalidação após ajuste de permissão de canal ainda bloqueada no nível do guild

- **Data:** 2026-04-15
- **Escopo:** repetir o provisionamento após ajuste de permissão de canal para a Cindy
- **Resultado:** a criação de categorias/canais/roles continuou retornando `Missing Permissions`; o ajuste de canal não concedeu permissão de gestão no nível do guild
- **Evidência:** `guilds/{guild}/channels`, `guilds/{guild}/roles`
- **Status:** Bloqueado

### TEST-S4-07 — WebUI local do Hermes validado

- **Data:** 2026-04-15
- **Escopo:** validar a subida da WebUI local do Hermes via `hermes dashboard` sem encerrar a sprint S4
- **Resultado:** `hermes dashboard --no-open --host 127.0.0.1 --port 9119` subiu com sucesso; o servidor respondeu em `http://127.0.0.1:9119` e a porta ficou em escuta local
- **Evidência:** `curl http://127.0.0.1:9119`, `ss -ltnp | rg ':9119'`
- **Status:** Passou

### TEST-S4-07 — Cockpit Discord provisionado com roles, categorias e canais base

- **Data:** 2026-04-15
- **Escopo:** criar as roles, categorias e canais previstos para o cockpit Discord após correção das permissões
- **Resultado:** as roles `Cindy`, `Builder`, `Reviewer`, `Documenter` e `PlatformOps` foram criadas; as categorias `PORTFOLIO`, `PO_GATES`, `AGENT_OPS`, `INCIDENTS`, `AUTOMATION`, `ARCHIVE` e `PROJECT | CindyAgent` foram criadas; os canais base foram provisionados sob suas categorias
- **Evidência:** `guilds/{guild}/roles`, `guilds/{guild}/channels`
- **Status:** Passou

### TEST-S4-08 — Smoke test de mensagem no canal Cindy executado com sucesso

- **Data:** 2026-04-15
- **Escopo:** validar que a Cindy consegue publicar mensagens no canal `cindy-commands`
- **Resultado:** a mensagem `Smoke test DOC2.5: Cindy operando no Discord no guild de teste...` foi postada com sucesso no canal `cindy-commands` e retornou pelo endpoint de mensagens do Discord
- **Evidência:** `channels/1493994494738305104/messages`
- **Status:** Passou

### TEST-S4-09 — Slash command `project status` registrado, mas sem resposta do aplicativo

- **Data:** 2026-04-15
- **Escopo:** validar a execução real do slash command `Project status` no início do canal `#proj-status`
- **Resultado:** o Discord exibiu `O aplicativo não respondeu`, indicando que o comando foi reconhecido pela plataforma, mas a Cindy ainda não responde à interação do slash command
- **Evidência:** UI do Discord com mensagem `O aplicativo não respondeu`
- **Status:** Bloqueado

### TEST-S4-10 — Catálogo do guild realinhado ao catálogo global atual do runtime Hermes

- **Data:** 2026-04-15
- **Escopo:** remover o catálogo stale de `project/task/review/approve/incident/handoff/sprint` do guild e espelhar o catálogo global atual do runtime Hermes
- **Resultado:** `PUT /applications/{app}/guilds/{guild}/commands` retornou `200` com `100` comandos; o catálogo do guild passou a conter `status` e não contém mais `project`
- **Evidência:** REST Discord `applications/{app}/commands` e `applications/{app}/guilds/{guild}/commands`
- **Status:** Passou

### TEST-S4-11 — `/status` validado end-to-end no cliente Discord

- **Data:** 2026-04-15
- **Escopo:** confirmar que o comando Hermes-aligned `/status` responde no cliente Discord após o realinhamento do catálogo do guild
- **Resultado:** `/status` respondeu com sucesso no Discord; o caminho mínimo operacional do runtime ficou validado sem depender do catálogo stale `project/*`
- **Evidência:** cliente Discord com resposta bem-sucedida do comando `/status`
- **Status:** Passou

### TEST-S4-12 — Validação Playwright do MVP Discord com canais paralelos

- **Data:** 2026-04-15
- **Escopo:** executar login web do Discord, abrir os canais `#geral` e `#runtime-status`, validar autocomplete mínimo e testar `/status`, `/help` e `/clear` em ambos os canais
- **Resultado:** login web concluído; autocomplete mostrou a superfície mínima com `/status`, `/help` e `/clear`; `/help` e `/clear` passaram nos dois canais; `/status` não retornou payload útil verificável no navegador dentro do timeout da bateria; `project` apareceu apenas como texto da árvore lateral do servidor, não como sugestão de slash command
- **Evidência:** sessão Playwright do Discord web, canais `1493981841747611671` e `1493994500287107225`, respostas dos comandos e DOM do client
- **Status:** Parcial
