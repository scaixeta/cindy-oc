# Hermes WebUI e Swarm

## Estado atual

Hermes Agent v0.9.0 suporta duas formas oficiais de uso que cobrem o pedido de “WebUI” e “Swarm”:

- **WebUI**: frontend web externo via API server OpenAI-compatible, com Open WebUI como integração oficial documentada.
- **Swarm**: operação paralela com múltiplas instâncias isoladas usando `hermes profile`, `--profile` e `--worktree`.

Se o termo “Swarm” for usado como sinônimo de vários agentes isolados em paralelo, a forma suportada no Hermes é por perfis e worktrees, não por um comando `hermes swarm` dedicado.

---

## WebUI oficial

### O que usar

- `hermes dashboard` para a UI web local de configuração, sessões e chaves
- Open WebUI para uma interface de chat completa conectada ao API server do Hermes

### Requisitos mínimos

- `API_SERVER_ENABLED=true`
- `API_SERVER_KEY=<segredo local>`
- gateway ativo
- Open WebUI apontando para `http://127.0.0.1:8642/v1` quando o cliente roda no mesmo host
- Open WebUI apontando para `http://host.docker.internal:8642/v1` quando o cliente roda em container no Windows/WSL

### Fluxo recomendado

1. Habilitar o API server no `.env` do Hermes.
2. Subir o gateway com `hermes gateway`.
3. Subir o Open WebUI com a URL base adequada ao host.
4. Confirmar que o modelo do Hermes aparece na UI.

### Observações operacionais

- A integração Open WebUI é server-to-server.
- Em geral, não é necessário configurar `API_SERVER_CORS_ORIGINS` para esse caso.
- Se a UI não listar modelos, validar o sufixo `/v1`, o endpoint `/health` e o cabeçalho de autorização.

---

## Swarm oficial

### O que usar

- `hermes profile list`
- `hermes profile create <nome>`
- `hermes profile use <nome>`
- `hermes -p <nome> chat ...`
- `hermes --worktree` quando a tarefa pedir isolamento de workspace em paralelo

### Modelo operacional

- Cada profile tem config, sessões, skills e diretório home próprios.
- `--profile` troca a instância ativa de forma explícita.
- `--worktree` ajuda a executar múltiplos fluxos sem misturar arquivos ou contexto local.

### Quando isso atende “Swarm”

- Quando o objetivo é rodar vários trabalhos em paralelo com isolamento de contexto.
- Quando cada linha de trabalho precisa de identidade própria, histórico próprio e config própria.

### O que não existe como comando nativo

- Não há, na referência oficial atual, um comando `hermes swarm` dedicado.
- O padrão suportado é `profile` + `worktree`.

---

## Validação rápida

### WebUI

- `curl http://127.0.0.1:8642/health`
- `curl http://127.0.0.1:8642/v1/models`
- abrir o Open WebUI na porta configurada localmente, normalmente `http://localhost:3000`

### Swarm

- `hermes profile list`
- `hermes -p <profile> chat -q "OK"`
- confirmar que duas execuções em profiles diferentes mantêm estado isolado

---

## Referências canônicas

- `KB/hermes/RUNTIME_EXPORT.md`
- `KB/hermes/README.md`
- documentação oficial do Hermes Agent sobre API Server, Open WebUI e CLI
