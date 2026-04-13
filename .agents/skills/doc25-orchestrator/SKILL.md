---
name: doc25-orchestrator
description: Orquestrar o fluxo DOC2.5 e a equipe de 5 agentes. Use quando for necessário decidir e encaminhar entre skills de inicialização, desenvolvimento, documentação, commit e operação multi-agente com gates de aprovação.
---

Selecione a skill correta com base na intenção do PO:

- Inicialização de contexto: usar `doc25-init`
- Desenvolvimento: usar `doc25-dev-workflow`
- Documentação: usar `doc25-docs-workflow`
- Commit/push: usar `doc25-commit-gate`
- Comunicação entre agentes: usar `dual-model-orchestrator`
- Operações IoT (ThingsBoard/n8n/Cirrus Lab): usar `sentivis-ops`

## Fluxo operacional da equipe
1. PO dá direção geral
2. Cindy tria e distribui (quem faz o quê)
3. Agentes discutem entre si via ACP (Redis) → geram plano de ação
4. Plano Reportado ao PO → Aprovação
5. Execução distribuída
6. Se algo grande → consultam PO
7. Retorno ao PO

## Regras de comunicação entre agentes
- Via ACP/Redis: JSON estruturado, nunca linguagem humana
- Agentes não se reportam diretamente ao PO — plano vai para Cindy que consolida
- GLM retorna para Cindy (não diretamente para MiniMax)
- Limite de 3-5 ciclos antes de escalar ao PO

Referências:
- `references/rules-map.md`
- `references/skill-routing.md`
- `docs/AGENT_TEAM_MODEL.md` (modelo operacional da equipe)
- `docs/ACP_PROTO.md` (especificação do protocolo ACP)