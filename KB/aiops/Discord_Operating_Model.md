# Discord_Operating_Model.md

## Estado Atual

O Discord foi adotado como cockpit de gestao da S4 da Cindy, com superficie MVP reduzida e operacao paralela por canal.

### Validacoes concluídas

- credenciais do bot validadas na API do Discord
- `install_params` atualizados para suportar `bot + applications.commands` no contexto de guild
- `Message Content Intent` habilitado no app
- o catálogo stale `project/*` do guild foi removido e alinhado ao runtime Hermes atual
- a superficie ativa do Discord foi reduzida ao MVP minimalista
- `/help` e `/clear` passaram na validacao Playwright do client
- a WebUI local do Hermes foi validada em `http://127.0.0.1:9119`
- `/status` continua exigindo revalidacao do payload util no navegador
- `project` na barra lateral do Discord representa a arvore de canais/categorias, nao um slash command vivo
- o runtime atual pode omitir skills por teto de 100 comandos, mas o catalogo vivo do guild permanece enxuto

### Limitação atual

- `project status` e `sprint status` ainda não foram implementados no runtime local do Hermes
- Discord -> ACP/Redis, reflexão canônica e cockpit multi-projeto completo continuam pendentes

---

## Modelo Operacional

### Papel do Discord

- receber comandos do PO e da equipe
- abrir tarefas, reviews e incidentes quando o runtime suportar isso
- exibir status operacional da Cindy
- refletir decisões e eventos para tracking canônico

### O que permanece canônico fora do Discord

- `Dev_Tracking.md`
- `Dev_Tracking_S4.md`
- `tests/bugs_log.md`
- docs canônicos em `docs/` e `KB/`
- A validacao do WebUI local complementa, mas nao encerra, a S4.

### Estrutura mínima de comandos viva

- `/status`
- `/help`
- `/clear`

### Comandos de cockpit ainda pendentes

- `project summary`
- `task create`
- `task assign`
- `task status`
- `review request`
- `approve plan`
- `incident open`
- `incident status`
- `handoff`
- `sprint status`

### Próximo passo operacional

- implementar os comandos de cockpit faltantes no runtime local se o objetivo for expor `project status` e `sprint status`
- ligar Discord -> Cindy -> ACP/Redis quando o catálogo do runtime estiver pronto para esses comandos
- repetir a validação de interação no servidor depois dessa implementação

### Nota de runtime atual

- Se o Discord mostrar `project status`, isso é catálogo stale ou outra instalação do app.
- O runtime Hermes atual expõe `/status`, `/help` e `/clear` como superficie minima.
- O cliente Discord validou `/help` e `/clear`, mas `/status` ainda precisa entregar payload util verificavel no navegador.

---

## Instalação

Link base de instalação:

`https://discord.com/oauth2/authorize?client_id=1493964369388765385&scope=bot%20applications.commands`

Observação:

- o guild alvo já foi definido; falta apenas manter o estado minimo sincronizado com a superficie ativa e revalidar `/status` no client
