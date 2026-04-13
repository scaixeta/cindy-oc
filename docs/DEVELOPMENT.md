# DEVELOPMENT.md — Desenvolvimento

## Visao Geral

O desenvolvimento atual do Cindy Agent permanece dentro da **Sprint S1**, ainda aberta, com foco em consolidar o runtime Hermes, a persona Cindy, a documentacao DOC2.5, a integracao do OpenCode CLI e o planejamento da replicacao entre os projetos principais da Cindy.

## Estado atual da sprint

- **Sprint ativa:** `S1`
- **Status:** aberta
- **Estorias:** 15 Done / 1 Pending (ST-S1-16: planejar replicacao)
- **Escopo corrente:** Hermes + Telegram + KB/hermes + docs canonicos + OpenCode + tracking

## Fluxo DOC2.5 aplicado neste projeto

```
1. entender o pedido
2. ler contexto mínimo necessário
3. separar fato, inferência e pendência
4. propor caminho proporcional ao impacto
5. se tarefa envolve mais de 1 agente → usar fluxo de equipe
6. executar a menor mudança necessária
7. registrar tracking e evidências
8. validar coerência documental
```

## Fluxo da equipe de 5 agentes

```
PO dá direção geral
    ↓
Cindy tria e distribui (quem faz o quê)
    ↓
Agentes discutem entre si via ACP (Redis) → geram plano de ação
    ↓
Plano Reported ao PO → Aprovação
    ↓
Execução distribuída
    ↓
Se algo grande → consultam PO
    ↓
Retorno ao PO
```

## Gates obrigatórios

| Gate | Regra |
|---|---|
| Planejamento | obrigatório antes de mudanças estruturais ou replicação multi-repo |
| Escrita | somente após entendimento claro do impacto |
| Commit/Push | apenas sob ordem explícita do PO |
| Fechamento de sprint | não permitido sem comando explícito do PO |
| Limite de iteração | 3-5 ciclos antes de escalar ao PO |

## Protocolo ACP

- Agentes se comunicam via Redis (Pub/Sub + Streams)
- Nunca em linguagem humana entre si — JSON estruturado
- Scripts: `.agents/scripts/acp_redis.py`, `.agents/scripts/test_acp_multi_agent.py`
- Gate de classificação: `dual_model_gate.py` (5 destinos: Sentivis, MiniMax, Scribe, GLM, Cindy)

## Escopo aprovado agora

### Dentro do escopo atual

- manter o repositorio-base Cindy Agent coerente com o estado real do Hermes
- OpenCode CLI como tool de delegacao para raciocinio profundo
- documentar KB/hermes e runtime vivo do Hermes
- documentar operacao via Telegram e gateway
- registrar os projetos principais da Cindy via `Replicar.md`
- planejar replicacao futura sem executa-la automaticamente

### Fora do escopo atual

- alterar em lote os repositorios listados em `Replicar.md`
- fechar a sprint S1
- automacao completa de deploy/servico do gateway

## Portfolio principal da Cindy

`Replicar.md` deve ser tratado como o mapa atual dos **projetos principais da Cindy**.

Repositorio principal de trabalho neste momento:

- `C:\01 - Sentivis\Sentivis SIM`

Planejamento futuro de replicacao por repositorio deve seguir esta ordem minima:

1. validar limpeza local (`git status`)
2. confirmar branch e remote
3. definir escopo exato da copia
4. registrar tracking local antes de alterar

## Escopo de replicacao planejado

Itens candidatos a replicacao controlada:

- skills relevantes
- docs canonicos
- Prompt / persona Cindy
- `Cindy_Contract.md`
- `rules/`
- workflows DOC2.5

## Politica Git

- `git status`, `git log`, `git show` → leitura permitida
- `git commit` e `git push` → somente com ordem explicita do PO
- nao assumir autorizacao por silencio

## Rastreabilidade minima

Toda mudanca relevante deve refletir:

- `README.md`
- `docs/`
- `Dev_Tracking.md`
- `Dev_Tracking_S1.md`
- `tests/bugs_log.md` quando houver bug ou teste real

## Qualidade

- alvo minimo de qualidade interna: **80/100**
- preferir mudanca minima, verificavel e reversivel
- documentar o estado real em vez de descrever arquitetura aspiracional

## Referencia

Consulte `Dev_Tracking_S1.md` para backlog, decisoes e pendencias da sprint ativa.
