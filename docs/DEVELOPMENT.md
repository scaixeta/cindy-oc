# DEVELOPMENT.md — Desenvolvimento

## Visao Geral

O desenvolvimento atual do Cindy Agent esta dentro da **Sprint S3**, com foco em materializar o time AIOps multiagente sem perder a base operacional do runtime Hermes, da KB canonica da Cindy e da documentacao DOC2.5.

## Estado atual da sprint

- **Sprint ativa:** `S3`
- **Status:** ativa
- **Escopo corrente:** time AIOps multiagente + Hermes/Telegram + KB/hermes + docs canonicos + tracking
- **Estado operacional validado em 2026-04-14:** `MiniMax-M2.7` primario no Hermes, `gpt-5.3-codex` como fallback, `hermes-gateway.service` ativo e healthcheck OK

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
PO da direcao geral
    ↓
Cindy tria e distribui (quem faz o que)
    ↓
Agentes discutem entre si via ACP (Redis) -> geram plano de acao
    ↓
Plano reportado ao PO -> aprovacao
    ↓
Execucao distribuida
    ↓
Se algo grande -> consultam o PO
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
- manter `MiniMax-M2.7` como primario do runtime Linux do Hermes e `gpt-5.3-codex` como fallback
- OpenCode CLI como tool de delegacao para raciocinio profundo
- documentar KB/hermes e runtime vivo do Hermes
- documentar operacao via Telegram e gateway
- registrar bugs, testes e decisoes da sprint ativa
- planejar evolucao multiagente sem executar mudancas estruturais fora do gate

### Fora do escopo atual

- alterar em lote os repositorios listados em `Replicar.md`
- fechar a sprint S3
- endurecer o bootstrap Windows do gateway sem aprovacao especifica

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
- `Dev_Tracking_S3.md`
- `tests/bugs_log.md` quando houver bug ou teste real

## Qualidade

- alvo minimo de qualidade interna: **80/100**
- preferir mudanca minima, verificavel e reversivel
- documentar o estado real em vez de descrever arquitetura aspiracional

## Referencia

Consulte `Dev_Tracking_S3.md` para backlog, decisoes e pendencias da sprint ativa.
