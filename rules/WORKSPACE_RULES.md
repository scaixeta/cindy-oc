# WORKSPACE_RULES.md - Regras Locais do Projeto

## Identificacao do Projeto

- Nome: Cindy OC
- Objetivo: Workspace derivado da Cindy para desenvolvimento local com governanca DOC2.5
- Papel atual: fonte local de regras, contrato, templates, tracking e skills minimas para Codex/Cline

## Natureza Operacional

Este arquivo e a fonte operacional obrigatoria do `Cindy OC`.

- governa leitura, execucao, alteracao, rastreabilidade e validacao no repositorio
- prevalece sobre resumos de `README.md`, `Cindy_Contract.md` e outros materiais explicativos

## Regras de Governanca

### Regra 1: Uma Sprint Ativa por Vez

Apenas um arquivo `Dev_Tracking_SX.md` pode estar ativo na raiz do projeto. Quando a sprint terminar, o arquivo deve ser movido para `Sprint/`.

### Regra 2: Estrutura Canonica

O projeto deve preservar, no minimo, a seguinte estrutura operacional:

```text
Cindy-OC/
├── README.md
├── Cindy_Contract.md
├── Dev_Tracking.md
├── Dev_Tracking_SX.md
├── docs/
│   ├── SETUP.md
│   ├── ARCHITECTURE.md
│   ├── DEVELOPMENT.md
│   └── OPERATIONS.md
├── rules/
│   └── WORKSPACE_RULES.md
├── tests/
│   └── bugs_log.md
├── Templates/
├── .brand/
├── .agents/
├── .cline/
├── .clinerules/
├── .codex/
└── Sprint/
```

### Regra 3: Ordem de Precedencia Operacional

Quando houver duvida ou conflito, a ordem de precedencia e:

1. `rules/WORKSPACE_RULES.md`
2. regras do runtime ativo
3. `Cindy_Contract.md`
4. `README.md`
5. `Dev_Tracking.md`, `Dev_Tracking_SX.md` e docs canonicos

### Regra 4: Ordem Canonica dos 4 Docs

Sequencia obrigatoria da documentacao canonica:

1. `docs/SETUP.md`
2. `docs/ARCHITECTURE.md`
3. `docs/DEVELOPMENT.md`
4. `docs/OPERATIONS.md`

`docs/README.md` e `docs/INDEX.md` nao fazem parte do modelo canonico DOC2.5.

### Regra 5: Modelo de Tracking

- `Dev_Tracking.md` e o indice mestre de sprints
- `Dev_Tracking_SX.md` e o tracking detalhado da sprint ativa
- `Sprint/` recebe apenas sprints encerradas
- `README.md`, `Dev_Tracking.md`, `Dev_Tracking_SX.md` e `tests/bugs_log.md` devem permanecer coerentes entre si

### Regra 6: Gate do PO

- mudancas estruturais exigem plano e aprovacao do PO quando extrapolarem o escopo corrente
- commit e push so podem ocorrer com ordem expressa do PO
- somente o PO pode encerrar sprint

### Regra 7: Timestamp UTC

Todo tracking deve conter a secao `Timestamp UTC` em tabela com 4 colunas:

```text
Event | Start | Finish | Status
```

Formato canonico:

- `YYYY-MM-DDTHH:MM:SS-ST`
- `YYYY-MM-DDTHH:MM:SS-FN`

### Regra 8: Evidencia, Inferencia e Pendencia

- fatos observaveis devem ser tratados como evidencia
- inferencias devem permanecer rotuladas
- confirmacoes do PO prevalecem sobre inferencias
- unknowns devem permanecer explicitos

### Regra 9: Limite de Integracoes Externas

- `OpenClaw` e camada externa opcional e desligada por padrao
- `Slack` nao e fonte de verdade do projeto
- `Railway`, `n8n`, `ThingsBoard` e qualquer servico externo so podem ser promovidos como parte operacional do projeto quando houver aprovacao e evidencia real
- nenhuma camada externa pode sobrepor o tracking DOC2.5 local

### Regra 10: README e Identidade de Projeto Derivado

- o nome do projeto deve refletir `Cindy OC`
- referencias a `Cindy` permanecem apenas quando falarem do orquestrador, do contrato ou do rodape oficial
- o `README.md` deve terminar com o bloco canonico da Cindy

### Regra 11: Estruturas Proibidas

Nao devem existir como parte do modelo canonico:

- `docs/README.md`
- `docs/INDEX.md`
- estruturas paralelas que dupliquem tracking, docs ou regras
- documentacao que afirme integracoes nao implantadas como se fossem reais

### Regra 12: Protecao de Credenciais em `.env`

- Arquivo `.env` nunca deve ser versionado (confirmar `.gitignore`)
- Edicoes em `.env` so podem modificar variaveis de configuracao
- Modificacoes em credenciais exigem:
  1. Backup SHA256 verificado
  2. Aprovacao explicita do PO
  3. Rastreabilidade em Dev_Tracking_SX
  4. Documentacao em CHANGELOG ou tests/bugs_log.md
- Variaveis classificadas como credenciais:
  - Prefixo `*_TOKEN`, `*_KEY`, `*_SECRET`
  - Campos explicitos: `PASSWORD`, `ENCRYPTION_KEY`, `API_TOKEN`
- Em caso de perda/adulteracao de credencial: invocar procedimento de recovery
- Referencias: `Wauzap/CR-S3-ENV-01`
