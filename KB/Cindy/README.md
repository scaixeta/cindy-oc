# Knowledge Base - Cindy

## Visao Geral

A KB da Cindy armazena o contexto operacional, memória de trabalho e configurações que definem como ela opera em cada workspace. Cada arquivo possui um propósito específico e deve ser consultado durante o entry flow.

---

## Estrutura da KB

```
KB/
├── SOUL.md       # Identidade, tom de voz e postura da Cindy
├── USER.md       # Preferências estáveis do operador atual
├── EMPRESA.md    # Contexto organizacional, PO e configurações da empresa
├── MEMORY.md     # Memória operacional e contexto de trabalho
└── activate_cindy_runtime.py  # Script de ativação do runtime
```

---

## Arquivos da KB

### SOUL.md

Define quem é a Cindy: identidade, tom de voz, postura operacional, comportamento e limites. Este é o arquivo de definição de character/role da Cindy.

**Quando ler**: Entry flow, contexto de interação, definição de tom.

### USER.md

Armazena as preferências estáveis do operador (usuário que interage com a Cindy). Inclui idioma, canais preferidos, regras de aprovação e padrões de comunicação.

**Quando ler**: Entry flow, personalização de respostas, compreensão de preferências.

### EMPRESA.md

Armazena o contexto organizacional da empresa onde a Cindy opera. Inclui dados da empresa, papel do PO, configurações operacionais, stack tecnológica, regras de negócio e estrutura de times.

**Quando ler**: Entry flow, personalização ao contexto empresa, validação de gates, referência de stacks e processos.

### MEMORY.md

Mantém memória operacional de trabalho: contexto de projetos ativos, últimas decisões, pendências e estado de execuções em andamento.

**Quando ler**: Resumo de contexto, continuidade de trabalho, rastreamento de estado.

## Estado Atual

- Data de referência: `2026-04-27`
- Sprint permanece aberta
- Time AIOps definido: `Cindy`, `AICoders`, `Escriba`, `Gateway`, `QA`
- `OpenCode` é o executor orquestrado pelos subagentes
- `Playwright` e `SonarScanner CLI` estão funcionais
- SonarQube local ainda depende do daemon Docker do host

---

## Entry Flow - Ordem de Leitura

```
CINDY_ENTRY:
  1. Ler rules/WORKSPACE_RULES.md
  2. Identificar orchestrator e superfície de execução
  3. Ler a regra global do runtime ativo (.clinerules/ ou .codex/)
  4. Classificar workspace (repo materializado ou baseline de geracao)
  5. Ler KB/SOUL.md
  6. Ler KB/USER.md
  7. Ler KB/EMPRESA.md
  8. Ler KB/MEMORY.md (quando existir)
  9. Consultar skill registry
  10. Validar gates obrigatórios
  11. Propor plano ao PO
```

---

## Preenchimento de EMPRESA.md

O arquivo EMPRESA.md deve ser preenchido com dados reais da organização:

1. **Dados da Empresa**: Nome, segmento, porte, operações
2. **Papel do PO**: Quem é, canais, gatilhos de aprovação
3. **Configurações Operacionais**: Infraestrutura, stack, ferramentas
4. **Estrutura de Times**: Times principais e hierarquia
5. **Regras de Negócio**: Processos, fluxos, SLAs, critérios
6. **Configurações do Projeto**: Projeto atual, repo, políticas
7. **Segurança e Compliance**: Requisitos e políticas
8. **Contatos de Emergência**: Suporte e escalação

---

## Manutencao

| Arquivo | Responsavel | Frequencia |
|---|---|---|
| SOUL.md | Cindy (self-maintained) | Quando.identity mudar |
| USER.md | Operador/PO | Quando preferencias mudarem |
| EMPRESA.md | PO ou responsavel | Quando contexto mudar |
| MEMORY.md | Cindy | A cada sessao/work |

---

## Hierarquia de Perfil do PO

Quando `KB/USER.md` e `KB/EMPRESA.md` especificarem preferências conflitantes do PO:

| Tipo de preferência | Fonte prevalente |
|---|---|
| Canal de interação principal | `KB/USER.md` |
| Formato de aprovação | `KB/USER.md` |
| Regras de gate (commit, push, sprint) | `rules/WORKSPACE_RULES.md` (Regra 9) |
| Contexto organizacional (stack, times, processos) | `KB/EMPRESA.md` |

**Regra operacional:**
- `USER.md` prevalece para preferências de interação pessoal
- `EMPRESA.md` prevalece para contexto organizacional e de projeto
- Gates de aprovação seguem sempre `rules/WORKSPACE_RULES.md`
- EMPRESA.md não pode criar gates paralelos aos já definidos

**Quando EMPRESA.md estiver vazio:**
- USER.md opera sozinho para preferências do operador
- Contexto organizacional fica em "modo padrão"
- Reportar pendência no Pre-Flight

---

## Modelo de Aprendizado

A arquitetura de aprendizado da Cindy está documentada em `KB/Rodadas/MODELO_APRENDIZADO_FASE2.md`.

**Conceito:** Aprendizado = CONHECIMENTO + CAPACIDADES acumulados ao longo do tempo.

**Resultado:** Agente com personalidade consistente, memória de fatos/preferências e habilidades aprendidas de experiência.

**Ciclo demonstrado:** R1 (26/100) → 6 correções → R2 (meta ≥80/100).

Consulte `MODELO_APRENDIZADO_FASE2.md` para detalhes da arquitetura de camadas e fluxo de acumulação.

---

## Regras de Uso

- Nunca versionar EMPRESA.md com dados sensíveis sem mascaramento
- USER.md pode conter informacoes pessoais do operador - tratar com cuidado
- MEMORY.md deve ser limpo periodicamente para evitar acumulo de contexto invalido
- EMPRESA.md e o arquivo mais extenso da KB - consultar apenas secoes relevantes

---

*KB canonica da Cindy - Modelo DOC2.5*
