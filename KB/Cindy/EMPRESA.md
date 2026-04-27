# EMPRESA - Contexto Organizacional e Customização

## Proposito

Este arquivo armazena o contexto organizacional da empresa onde a Cindy opera, incluindo dados da empresa, papel do PO, configurações operacionais e regras de negócio específicas. A Cindy deve consultar este arquivo durante o entry flow para personalizar seu comportamento e respostas ao contexto específico da organização.

---

## 1. Dados da Empresa

### Identificacao

| Campo | Valor |
|---|---|
| Nome da empresa | `{{NOME_EMPRESA}}` |
| Segmento/Setor | `{{SEGMENTO}}` |
| Porte | `{{PORTE}}` |
| CNPJ | `{{CNPJ}}` |

### Operacao

| Campo | Valor |
|---|---|
| Localizacao headquarters | `{{LOCALIZACAO}}` |
| Areas principais | `{{AREAS}}` |
| Sistemas principais | `{{SISTEMAS}}` |

---

## 2. Papel do PO (Product Owner)

### PO Atual

| Campo | Valor |
|---|---|
| Nome | `{{NOME_PO}}` |
| Cargo | `{{CARGO_PO}}` |
| Email | `{{EMAIL_PO}}` |
| Canal preferido | `{{CANAL_PO}}` |

### Gatilhos e Restricoes do PO

| Gatilho | Detalhamento |
|---|---|
| Aprovacao de plano | `{{REGRA_APROVACAO}}` |
| Autorizacao commit/push | `{{REGRA_COMMIT}}` |
| Encerramento de sprint | `{{REGRA_ENCERRAMENTO}}` |
| Critérios de aceite | `{{CRITERIOS_ACEITE}}` |

### Preferencias do PO

- `{{PREFERENCIA_1}}`
- `{{PREFERENCIA_2}}`
- `{{PREFERENCIA_3}}`

---

## 3. Configuracoes Operacionais

### Infraestrutura

| Tipo | Detalhamento |
|---|---|
| Ambiente principal | `{{AMBIENTE_PRINCIPAL}}` |
| Cloud/On-prem/Hibrido | `{{INFRA_TIPO}}` |
| Provedor cloud | `{{CLOUD_PROVIDER}}` |

### Stack Tecnologica

| Categoria | Tecnologias |
|---|---|
| Backend | `{{BACKEND}}` |
| Frontend | `{{FRONTEND}}` |
| Database | `{{DATABASE}}` |
| DevOps/Infra | `{{DEVOPS}}` |
| Messaging/APIs | `{{MESSAGING}}` |

### Feramentas e Plataformas

| Feramenta | Uso |
|---|---|
| `{{FERRAMENTA_1}}` | `{{USO_1}}` |
| `{{FERRAMENTA_2}}` | `{{USO_2}}` |
| `{{FERRAMENTA_3}}` | `{{USO_3}}` |

---

## 4. Estrutura de Times

### Nota Operacional Importante

> ⚠️ **Os times definidos nesta seção são a estrutura organizacional real da empresa.** Eles NÃO mapeiam diretamente para as funções da equipe de orquestração (Cindy, AICoders, Escriba, Gateway, QA) definidas na Regra 27 do `rules/WORKSPACE_RULES.md`.
>
> **Relação:**
> - Times humanos (esta seção): organizam pessoas, responsabilidade e canais de comunicação da empresa
> - Agentes de orquestração (Regra 27): alocam work de IA entre especialidades técnicas
>
> Quando a Cindy precisar despachar trabalho para times humanos, ela consultará esta seção.
> Quando a Cindy precisar alocar tarefas entre agentes internos, usará o gate semântico da Regra 27.

### Times Principais

| Time | Responsavel | Canais |
|---|---|---|
| `{{TIME_1}}` | `{{RESP_1}}` | `{{CANAL_1}}` |
| `{{TIME_2}}` | `{{RESP_2}}` | `{{CANAL_2}}` |
| `{{TIME_3}}` | `{{RESP_3}}` | `{{CANAL_3}}` |

### Hierarquia Operacional

```
`{{HIERARQUIA}}`
```

---

## 5. Regras de Negocio

### Processos de Aprovacao

| Processo | Responsavel | Gate |
|---|---|---|
| `{{PROCESSO_1}}` | `{{RESP_PROC_1}}` | `{{GATE_1}}` |
| `{{PROCESSO_2}}` | `{{RESP_PROC_2}}` | `{{GATE_2}}` |

### Fluxos de Trabalho

| Fluxo | Descricao | SLAs |
|---|---|---|
| `{{FLUXO_1}}` | `{{DESC_FLUXO_1}}` | `{{SLA_1}}` |
| `{{FLUXO_2}}` | `{{DESC_FLUXO_2}}` | `{{SLA_2}}` |

### Criterios de Qualidade

- `{{CRITERIO_QUALIDADE_1}}`
- `{{CRITERIO_QUALIDADE_2}}`
- `{{CRITERIO_QUALIDADE_3}}`

---

## 6. Configuracoes Especificas do Projeto

### Projeto Atual

| Campo | Valor |
|---|---|
| Nome do projeto | `{{PROJETO_ATUAL}}` |
| Fase atual | `{{FASE_ATUAL}}` |
| Sprint ativa | `{{SPRINT_ATIVA}}` |
| Escopo aprovado | `{{ESCOPO_APROVADO}}` |

### Repository Info

| Campo | Valor |
|---|---|
| Repository principal | `{{REPO_PRINCIPAL}}` |
| Branch default | `{{BRANCH_DEFAULT}}` |
| Politica de branches | `{{POLITICA_BRANCHES}}` |

---

## 7. Seguranca e Compliance

### Requisitos de Seguranca

- `{{REQUISITO_SEG_1}}`
- `{{REQUISITO_SEG_2}}`
- `{{REQUISITO_SEG_3}}`

### Politicas de Compliance

- `{{COMPLIANCE_1}}`
- `{{COMPLIANCE_2}}`
- `{{COMPLIANCE_3}}`

---

## 8. Contatos de Emergencia

| Tipo | Nome | Contato |
|---|---|---|
| Suporte TI | `{{SUPORTE_TI}}` | `{{CONTATO_TI}}` |
| Escalacao | `{{ESCALACAO}}` | `{{CONTATO_ESCALACAO}}` |

---

## 9. Notas Operacionais

### Contexto Adicional

`{{NOTAS_OPERACIONAIS}}`

### Historico de Decisoes Importantes

- `{{DECISAO_1}}`
- `{{DECISAO_2}}`

---

## Modo de Uso

A Cindy deve ler este arquivo durante o entry flow para:

1. Identificar o contexto organizacional
2. Personalizar respostas ao perfil do PO
3. Validar gates de aprovação contra as regras da empresa
4. Referenciar stacks, ferramentas e processos específicos
5. Manter rastreabilidade de decisões organizacionais

**Mantenedor**: PO ou responsável definido pela empresa.
**Ultima atualizacao**: `{{DATA_ATUALIZACAO}}`

---

*Este arquivo faz parte do KB canonico da Cindy e deve ser atualizado sempre que houver mudanca de contexto organizacional.*
