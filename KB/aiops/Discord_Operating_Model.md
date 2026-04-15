# Discord_Operating_Model.md

## Estado Atual

O Discord foi adotado como cockpit de gestao da S4 da Cindy.

### Validacoes concluídas

- credenciais do bot validadas na API do Discord
- `install_params` atualizados para suportar `bot + applications.commands` no contexto de guild
- conjunto mínimo de comandos slash registrado globalmente
- `DISCORD_GUILD_ID` configurado no ambiente local

### Limitação atual

- a instalação do app no guild de teste ainda está bloqueada no acesso do bot ao servidor

---

## Modelo Operacional

### Papel do Discord

- receber comandos do PO e da equipe
- abrir tarefas, reviews e incidentes
- exibir status operacional da Cindy
- refletir decisões e eventos para tracking canônico

### O que permanece canônico fora do Discord

- `Dev_Tracking.md`
- `Dev_Tracking_S4.md`
- `tests/bugs_log.md`
- docs canônicos em `docs/` e `KB/`

### Estrutura mínima de comandos registrada

- `project status`
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

- instalar o app em um guild de teste com o link OAuth2 gerado a partir do `Application ID`
- validar o fluxo de interação real no servidor
- repetir o registro de comandos no contexto do guild assim que o bot estiver autorizado

---

## Instalação

Link base de instalação:

`https://discord.com/oauth2/authorize?client_id=1493964369388765385&scope=bot%20applications.commands`

Observação:

- o guild alvo já foi definido; falta apenas autorização efetiva do bot no servidor
