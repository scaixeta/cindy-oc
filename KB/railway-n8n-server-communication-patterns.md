# KB - Como Replicar o Contexto Operacional entre VSCode, Cline, n8n e Servidores

## Proposito

Este documento consolida, de forma generica e reutilizavel, o modo de trabalho observado a partir do projeto `FinTechN8N`, portado para o `Cindy OC` como referencia de operacao para projetos futuros.

Fonte analisada:

- `C:\Users\sacai\OneDrive\Documentos\FinTechN8N`

Escopo desta KB:

- como o ambiente e criado e operado via VSCode, Cline e arquivos versionados
- como o n8n local e remoto entram no fluxo de trabalho
- como os workflows sao construidos, exportados, ajustados e reaplicados
- como ocorre o acesso a servidores, APIs e banco
- guardrails operacionais e de seguranca

Fora de escopo:

- credenciais reais
- URLs privadas reais
- tokens, API keys ou segredos
- replicacao literal de configuracoes especificas do projeto de origem

## 1. O Que Importa Reaproveitar

O principal aprendizado do projeto de origem nao e o ETL em si. O que vale clonar para outra aplicacao e o metodo:

- desenvolver no VSCode com apoio de agentes
- usar Cline/Codex para navegar, editar, auditar e documentar o projeto
- subir o ambiente local por `docker compose`
- construir o workflow no n8n, mas tratar partes densas como codigo versionavel
- acessar servidor local, remoto, banco e APIs com contratos claros
- separar segredos do repositorio
- registrar o processo em docs e scripts para tornar a reproducao previsivel

## 2. Ferramentas e Papeis no Processo

### 2.1 VSCode como base de desenvolvimento

No modelo observado, o VSCode e o centro de trabalho para:

- abrir o workspace inteiro
- editar scripts, SQL, documentacao e frontend
- acionar extensoes e agentes
- acompanhar os arquivos exportados do n8n
- manter o repositario organizado

O VSCode nao substitui o n8n. Ele funciona como a base onde o projeto vive fora do canvas visual.

### 2.2 Cline e Codex como camada de execucao assistida

O Cline e o Codex entram como aceleradores operacionais:

- leem regras do workspace
- inspecionam a estrutura do projeto
- geram ou ajustam scripts
- ajudam a transformar alteracoes do workflow em artefatos reutilizaveis
- documentam o que foi decidido
- reduzem a dependencia de edicao manual espalhada

No repositorio analisado, isso aparece no uso de:

- `QUICKSTART.md` para ativacao dos runtimes
- `scripts/install_cline_cli.ps1` para instalar o Cline CLI
- `scripts/sync_skills.ps1` para sincronizar skills
- `.clinerules/`, `.codex/` e `.agent/` como pontos de entrada dos diferentes orquestradores

### 2.3 n8n como editor visual e runtime

O n8n cumpre dois papeis ao mesmo tempo:

- runtime de automacao
- editor visual de workflow

Mas o projeto nao depende apenas da tela do n8n. A pratica observada e:

- desenhar ou ajustar o fluxo no editor visual quando isso for mais rapido
- exportar o workflow ou consultar a API publica do n8n
- editar as partes mais densas fora do n8n, em arquivos locais
- reaplicar o workflow por script

Esse ponto e essencial para repetir o contexto em outra aplicacao.

## 3. Como o Ambiente e Criado

### 3.1 Bootstrap local

O padrao base e:

1. clonar o repositorio no workspace
2. abrir no VSCode
3. preparar variaveis sensiveis fora do versionamento
4. subir containers com `docker compose`
5. acessar a UI do n8n e o banco

No caso observado, `docker-compose.yml` sobe os servicos principais e o n8n monta o workspace como volume. Isso permite que o workflow leia arquivos e scripts do proprio projeto.

### 3.2 Segredos e acessos

O padrao de acesso e simples, mas importante:

- credenciais nao ficam em arquivos versionados
- `.env` e arquivos locais equivalentes guardam chaves e senhas
- o n8n usa credenciais internas para banco e APIs
- scripts externos usam API key do n8n apenas a partir de fonte local segura

Em projetos novos, a regra deve ser a mesma:

- local: `.env` fora do Git
- remoto: secret manager ou variaveis de ambiente da plataforma

### 3.3 Acesso a servidores

O contexto analisado combina mais de um tipo de acesso:

- n8n local em Docker
- banco local em container
- possibilidade de n8n remoto
- APIs ou servicos remotos em Railway

O desenho operacional recomendado para reaproveitar e:

- desenvolvimento e depuracao primeiro no local
- exposicao remota apenas do que precisa ser publico
- uso de APIs autenticadas para ligar n8n e backend remoto
- banco com credenciais segregadas por consumidor

## 4. Como os Workflows do n8n Sao Construidos

### 4.1 Construcao inicial

O fluxo costuma nascer na interface do n8n, porque:

- o desenho visual acelera testes
- os nodes e conexoes ficam mais evidentes
- facilita entender o encadeamento das etapas

### 4.2 Refinamento fora da interface

Quando o workflow cresce, o projeto passa a usar um metodo hibrido:

- manter o desenho geral no n8n
- mover ajustes densos para scripts e JSONs locais

Exemplos observados no projeto:

- `fetch_latest_wf.js`
- `push_wf_final.js`
- `scripts/update_w4.js`
- `wf_current.json`
- `all_workflows.json`

Esse metodo resolve um problema comum: editar node `Code`, query SQL e conexoes complexas diretamente no canvas pode ser lento, opaco e sujeito a erro.

### 4.3 Ciclo pratico de manutencao

O ciclo reutilizavel e:

1. abrir ou testar o workflow no n8n
2. exportar o JSON ou buscar o workflow atual pela API
3. salvar esse estado no workspace
4. editar localmente com apoio do VSCode e dos agentes
5. limpar o payload para manter apenas os campos aceitos pela API
6. reenviar com `PUT /api/v1/workflows/:id`
7. reativar o workflow e validar

### 4.4 O que vai para codigo e o que fica no canvas

Boa divisao observada:

- canvas: estrutura do fluxo, nodes, conexoes, testes rapidos
- codigo local: JS complexo, SQL extenso, patches estruturais, versionamento de artefatos

Em outras palavras: o n8n continua sendo o orquestrador, mas o workspace passa a ser o lugar onde o conhecimento fica preservado.

## 5. Como Cline e VSCode Entram na Construcao do Workflow

O processo mais reaproveitavel para novos projetos e:

1. desenhar uma primeira versao no n8n
2. exportar o workflow
3. abrir o JSON e scripts no VSCode
4. pedir ao Cline ou Codex para revisar, ajustar ou refatorar trechos densos
5. reaplicar no n8n por script
6. registrar o resultado em documentacao

Isso transforma a criacao do workflow em algo menos manual e mais rastreavel.

Beneficios praticos:

- reproducao mais facil em outro projeto
- menor dependencia da memoria de quem montou o fluxo
- chance maior de reaproveitar blocos
- manutencao menos dolorosa
- melhor colaboracao entre quem entende negocio, n8n e codigo

## 6. Padrao de Acesso entre Local, Remoto e Servicos

### 6.1 Local para local

Padrao:

`VSCode/Cline -> arquivos locais -> docker compose -> n8n local -> banco local`

Serve para:

- desenvolvimento
- depuracao
- testes de workflow
- validacao de SQL e scripts auxiliares

### 6.2 Local para remoto

Padrao:

`n8n local ou scripts locais -> API remota em Railway`

Serve para:

- sincronizar com backend publicado
- consumir servicos externos do projeto
- validar contratos reais antes de mover tudo para producao

### 6.3 Remoto para n8n

Padrao:

`servico remoto -> webhook n8n`

Serve para:

- disparar automacoes
- iniciar processamento por evento
- integrar backend principal com automacao visual

### 6.4 Remoto para banco

Padrao:

`n8n/API/worker -> Postgres`

A recomendacao portavel continua sendo:

- banco como persistencia e fonte de verdade
- n8n e aplicacao acessando com credenciais separadas
- regras de acesso minimas por papel

## 7. Principios Portaveis

- Railway deve ser tratado como camada de infraestrutura e hospedagem, nao como fonte de verdade do projeto
- n8n funciona bem como orquestrador de fluxos, integrador HTTP, scheduler e ponte entre sistemas
- a fonte de verdade operacional precisa ficar explicita: banco, API principal, workflow ou tracking DOC2.5
- toda comunicacao entre servicos deve ter contrato minimo: origem, destino, autenticacao, timeout, retry e observabilidade
- segredos nunca devem ser versionados

## 8. Topologias de Comunicacao Reutilizaveis

### 8.1 n8n como orquestrador central

Padrao:

`Trigger -> n8n -> API/DB/Worker -> consolidacao -> callback/webhook/armazenamento`

Quando usar:

- automacao orientada a eventos
- sincronizacao entre sistemas
- jobs agendados
- pipelines ETL

Responsabilidade do n8n:

- receber evento
- transformar payload
- chamar APIs
- escrever em banco quando apropriado
- consolidar resposta
- notificar outro sistema

### 8.2 Railway como camada de servicos

Padrao:

`Client/Agent/n8n -> Railway service -> DB/queue/internal service`

Quando usar:

- hospedar API publica ou privada
- executar workers
- expor endpoints para webhooks
- centralizar acesso a banco, cache ou filas

Responsabilidade do Railway:

- hospedar servicos
- injetar variaveis de ambiente
- permitir deploy e observabilidade
- oferecer endpoints publicos ou servico interno conforme o caso

### 8.3 n8n + banco relacional

Padrao:

`Trigger/API/Webhook -> n8n -> Postgres`

Boas aplicacoes:

- staging de eventos
- ETL
- auditoria de payloads
- consolidacao e relatorios

Boas praticas:

- persistir ids externos para idempotencia
- usar chave de deduplicacao
- manter trilha de origem do payload
- separar dados brutos de dados normalizados quando houver ETL

### 8.4 API principal + n8n como worker de automacao

Padrao:

`App/API principal -> webhook n8n -> steps de automacao -> callback para API principal`

Quando usar:

- a aplicacao central precisa continuar dona do dominio
- o n8n executa automacoes, nao regras centrais de negocio
- ha necessidade de workflow visual, retries e integracoes multiplas

## 9. Canais de Comunicacao entre Servidores

### 9.1 HTTP publico

Usar quando:

- o servico precisa receber webhooks externos
- um frontend ou sistema terceiro precisa chamar a API
- o n8n precisa expor endpoint publico

Exemplos:

- webhook do n8n
- API em Railway
- callback de processamento

Cuidados:

- autenticacao obrigatoria
- rate limit quando aplicavel
- validacao de assinatura ou token
- CORS somente se realmente necessario

### 9.2 Comunicacao interna entre servicos

Usar quando:

- servicos estao na mesma plataforma ou mesma malha privada
- o endpoint nao deve ser publico
- um worker precisa falar com API ou banco sem exposicao externa

Preferencia:

- servico interno sobre endpoint publico quando a chamada nao precisa sair para internet

### 9.3 Acesso a banco

Usar quando:

- n8n ou servico precisa persistir, ler ou consolidar dados

Padrao recomendado:

- banco como dependencia de servicos e workflows
- aplicacao e n8n acessam o banco por credenciais separadas
- privilegios minimos por papel

### 9.4 Fila ou mensageria

Usar quando:

- processamentos demoram
- ha necessidade de desacoplamento
- o volume justifica retry assincrono

Padrao:

`API -> queue -> worker`

n8n pode entrar como:

- produtor de mensagens
- consumidor leve
- coordenador de jobs

## 10. Padroes Especificos para Railway + n8n

### 10.1 n8n hospedado no Railway

Topologia:

`Internet/internal caller -> n8n on Railway -> Postgres/Redis/API services`

Usar quando:

- deseja-se centralizar a automacao na mesma plataforma
- o n8n precisa conversar com servicos hospedados em Railway

Necessidades minimas:

- persistencia para n8n
- encryption key estavel
- banco externo ou dedicado
- dominio/URL canonicamente definida

### 10.2 n8n fora do Railway e APIs no Railway

Topologia:

`n8n external/self-hosted -> Railway API -> Railway DB/internal services`

Usar quando:

- n8n ja existe fora da plataforma
- Railway sera usado apenas para apps e servicos
- quer-se reduzir acoplamento entre automacao e hospedagem principal

### 10.3 Railway como backend e n8n como camada de automacao

Padrao recomendado:

- regras centrais de negocio na API/backend
- automacoes, ETL, notificacoes e sync no n8n
- callbacks e webhooks com contrato claro

Evitar:

- colocar toda a regra central de negocio apenas no n8n
- depender de webhooks sem idempotencia
- misturar automacao com dados sem trilha de auditoria

## 11. Contratos Minimos de Integracao

Para cada integracao, documentar no minimo:

- origem
- destino
- protocolo
- autenticacao
- payload de entrada
- payload de saida
- timeout
- retry
- comportamento em erro
- observabilidade

Checklist minimo:

| Item | Exigencia |
|---|---|
| Identidade da chamada | Quem chama quem |
| Exposicao | Publica ou interna |
| Autenticacao | API key, bearer, assinatura, mTLS ou equivalente |
| Idempotencia | Chave de deduplicacao ou correlation id |
| Persistencia | Onde o resultado e registrado |
| Falha | Retry, dead-letter ou log manual |
| Evidencia | Logs, execucoes do n8n, metricas, bugs_log |

## 12. Padroes de Operacao e Observabilidade

### 12.1 Logs

Registrar:

- request id
- workflow id ou execution id
- service name
- status da chamada
- erro resumido

### 12.2 Correlation ID

Recomendado em:

- webhook para API
- API para worker
- n8n para banco ou callback

Objetivo:

- rastrear ponta a ponta a mesma operacao

### 12.3 Evidencia minima

Manter evidencia em:

- logs do servico
- logs/executions do n8n
- tracking DOC2.5
- bugs_log quando houver incidente ou validacao relevante

## 13. Procedimento Validado de Login no Railway

### 13.1 Contexto

Durante a tentativa de login da Railway CLI, o fluxo pode falhar por:

- ambiente nao interativo
- `node` fora do `PATH` do terminal atual

No ambiente validado, a CLI estava em:

- `C:\Users\sacai\AppData\Roaming\npm\railway.ps1`

E o `node.exe` estava disponivel em:

- `C:\Program Files\nodejs\node.exe`

### 13.2 Procedimento validado

Abrir um terminal `PowerShell` do Windows e executar:

```powershell
$env:Path = "C:\Program Files\nodejs;$env:Path"
& "C:\Users\sacai\AppData\Roaming\npm\railway.ps1" login
```

### 13.3 Validacao opcional antes do login

```powershell
$env:Path = "C:\Program Files\nodejs;$env:Path"
& "C:\Users\sacai\AppData\Roaming\npm\railway.ps1" --version
```

### 13.4 Validacao de login concluido

```powershell
cmd /c "set PATH=C:\Program Files\nodejs;%PATH% && C:\Users\sacai\AppData\Roaming\npm\railway.cmd whoami"
```

Resultado esperado:

- usuario autenticado na Railway CLI

### 13.5 Verificacao de vinculo do projeto

```powershell
cmd /c "set PATH=C:\Program Files\nodejs;%PATH% && C:\Users\sacai\AppData\Roaming\npm\railway.cmd status"
```

Se o retorno indicar `No linked project found`, isso significa:

- login realizado com sucesso
- o workspace local ainda nao foi vinculado a um projeto Railway

### 13.6 Estado Tecnico Validado no Cindy OC

Esta KB tambem passou a servir como referencia tecnica complementar do estado real do `Cindy OC`, alem do papel generico de portabilidade.

Estado validado na sprint `S0`:

- `Railway` ativo como camada de servicos do MVP
- `Postgres` saudavel em Railway
- `n8n-runtime` implantado em Railway com imagem fixa `n8nio/n8n:1.64.0`
- dominio publico validado: `https://n8n-runtime-production.up.railway.app`
- conectividade com banco validada por logs e migracoes
- API publica do n8n validada com `GET /api/v1/workflows` retornando `200`

Decisoes operacionais associadas:

- o servico antigo `n8n` permanece apenas como pendencia de limpeza futura
- `Slack` foi descartado como canal MVP nesta fase
- `Telegram` passa a ser o canal conversacional priorizado para a proxima etapa
- `OpenClaw` segue externo e fora do escopo de implementacao corrente

Guardrail importante:

- o estado validado acima nao substitui `README.md`, `Dev_Tracking.md` e `Dev_Tracking_S0.md`; ele apenas consolida a leitura tecnica de Railway + n8n como referencia complementar

## 14. Guardrails de Seguranca

- nunca versionar tokens, API keys, strings de conexao ou segredos
- evitar endpoints publicos quando servico interno resolver
- separar credenciais por servico
- limitar permissoes do n8n no banco
- validar payloads recebidos antes de persistir ou encaminhar
- mascarar dados sensiveis em logs

Observacao importante:

O material de origem contem exemplos locais de API e automacao. Nesta portabilidade, esses detalhes foram abstratizados e nenhum segredo foi reaproveitado.

## 15. Padroes de Erro e Recuperacao

### 15.1 Falhas comuns

- webhook indisponivel
- credencial invalida
- timeout entre servicos
- payload rejeitado por schema
- duplicidade em reprocessamento
- dependencia externa fora do ar

### 15.2 Respostas recomendadas

- retry com limite
- persistencia de erro para reprocessamento
- idempotencia por chave externa
- dead-letter ou fila de falhas para alto volume
- registro do incidente em `tests/bugs_log.md`

## 16. Matrizes de Uso Rapido

### 16.1 Quando usar Railway

| Cenario | Railway faz sentido? | Observacao |
|---|---|---|
| API principal | Sim | Bom para hospedar backend e endpoints |
| Worker/cron | Sim | Bom para jobs e servicos auxiliares |
| Banco gerenciado | Sim | Quando houver necessidade de persistencia |
| Automacao visual | Sim, opcional | Pode hospedar n8n ou apenas APIs |

### 16.2 Quando usar n8n

| Cenario | n8n faz sentido? | Observacao |
|---|---|---|
| Webhooks e integracoes | Sim | Forte para orquestracao |
| ETL | Sim | Bom para pipelines e transformacoes |
| Regras centrais complexas de dominio | Com cautela | Melhor manter o nucleo em backend dedicado |
| Jobs agendados | Sim | Forte em schedule e fan-out |

### 16.3 Quando introduzir outro servidor

| Tipo | Quando incluir |
|---|---|
| Redis | cache, locks, filas leves |
| Postgres | persistencia, auditoria, relatorios |
| Worker dedicado | tarefas pesadas ou demoradas |
| Reverse proxy/API gateway | consolidacao de entrada, TLS, roteamento |

## 17. Blueprint Generico para Novos Projetos

Sequencia recomendada:

1. Definir a fonte de verdade do dominio
2. Definir se o n8n sera orquestrador, integrador ou apenas ferramenta auxiliar
3. Definir o papel do Railway: hospedagem de API, n8n, banco, worker ou combinacao
4. Definir quais chamadas devem ser internas e quais precisam ser publicas
5. Definir autenticacao e estrategia de idempotencia
6. Definir observabilidade minima
7. Implantar primeiro o contrato, depois a infraestrutura, depois os fluxos

## 18. Decisoes Portaveis para Cindy OC

Estas diretrizes podem ser reaproveitadas em outros projetos do ecossistema Cindy:

- Railway como camada de servicos e hospedagem
- n8n como camada de orquestracao e automacao
- banco como trilha de auditoria e persistencia quando aplicavel
- DOC2.5 como camada de governanca e rastreabilidade

## 19. Pendencias de Validacao

- escolher em cada projeto se o n8n ficara dentro ou fora do Railway
- definir padrao oficial de autenticacao entre servicos do ecossistema
- definir quando usar fila em vez de chamadas HTTP diretas
- definir um modelo canonico de contrato entre workflow, API e worker

### 2.4 API principal + n8n como worker de automacao

Padrao:

`App/API principal -> webhook n8n -> steps de automacao -> callback para API principal`

Quando usar:

- a aplicacao central precisa continuar dona do dominio
- o n8n executa automacoes, nao regras centrais de negocio
- ha necessidade de workflow visual, retries e integracoes multiplas

## 2.5 Padrao concreto observado no FinTechN8N

O projeto analisado implementa um padrao especialmente reutilizavel para cenarios de ETL, consolidacao e exposicao de dados:

`Arquivos locais -> n8n local em Docker -> Postgres -> camada de categorizacao/SSOT -> webhook/API de consumo`

Componentes observados:

- `docker-compose.yml` sobe pelo menos `n8n`, `postgres`, `pgadmin` e um `frontend`
- o container do n8n monta o workspace inteiro como volume em `/workspace`
- a pasta de entrada real fica em `Documentos Bancarios/`
- o n8n le arquivos `OFX`, `CSV` e `PDF` diretamente do filesystem compartilhado
- PDFs sao tratados por script Python externo chamado a partir de node de codigo no n8n
- OFX e CSV sao parseados no proprio workflow em Javascript
- o Postgres recebe primeiro os metadados brutos e depois os dados normalizados
- views SQL consolidam a SSOT e removem duplicidade logica entre fontes
- um webhook do n8n atende a camada de dashboard/consumo

O ponto mais portavel aqui nao e o dominio financeiro em si, e sim a separacao de responsabilidades:

- filesystem ou storage como camada de entrada
- n8n como motor de orquestracao e transformacao
- banco como persistencia resiliente e fonte de verdade
- camada de consumo separada da camada de ingestao

## 3. Canais de Comunicacao entre Servidores

### 3.1 HTTP publico

Usar quando:

- o servico precisa receber webhooks externos
- um frontend ou sistema terceiro precisa chamar a API
- o n8n precisa expor endpoint publico

Exemplos:

- webhook do n8n
- API em Railway
- callback de processamento

Cuidados:

- autenticacao obrigatoria
- rate limit quando aplicavel
- validacao de assinatura ou token
- CORS somente se realmente necessario

### 3.2 Comunicacao interna entre servicos

Usar quando:

- servicos estao na mesma plataforma ou mesma malha privada
- o endpoint nao deve ser publico
- um worker precisa falar com API ou banco sem exposicao externa

Preferencia:

- servico interno sobre endpoint publico quando a chamada nao precisa sair para internet

### 3.3 Acesso a banco

Usar quando:

- n8n ou servico precisa persistir, ler ou consolidar dados

Padrao recomendado:

- banco como dependencia de servicos e workflows
- aplicacao e n8n acessam o banco por credenciais separadas
- privilegios minimos por papel

### 3.4 Fila ou mensageria

Usar quando:

- processamentos demoram
- ha necessidade de desacoplamento
- o volume justifica retry assíncrono

Padrao:

`API -> queue -> worker`

n8n pode entrar como:

- produtor de mensagens
- consumidor leve
- coordenador de jobs

## 4. Padroes Especificos para Railway + n8n

### 4.1 n8n hospedado no Railway

Topologia:

`Internet/internal caller -> n8n on Railway -> Postgres/Redis/API services`

Usar quando:

- deseja-se centralizar a automacao na mesma plataforma
- o n8n precisa conversar com servicos hospedados em Railway

Necessidades minimas:

- persistencia para n8n
- encryption key estavel
- banco externo ou dedicado
- dominio/URL canonicamente definida

### 4.2 n8n fora do Railway e APIs no Railway

Topologia:

`n8n external/self-hosted -> Railway API -> Railway DB/internal services`

Usar quando:

- n8n ja existe fora da plataforma
- Railway sera usado apenas para apps e servicos
- quer-se reduzir acoplamento entre automacao e hospedagem principal

### 4.3 Railway como backend e n8n como camada de automacao

Padrao recomendado:

- regras centrais de negocio na API/backend
- automacoes, ETL, notificacoes e sync no n8n
- callbacks e webhooks com contrato claro

Evitar:

- colocar toda a regra central de negocio apenas no n8n
- depender de webhooks sem idempotencia
- misturar automacao com dados sem trilha de auditoria

### 4.4 Railway replicando o modelo FinTechN8N

Para clonar o contexto do projeto de origem em outra aplicacao, o desenho recomendado fica:

`Origem de dados -> n8n -> Postgres -> API/Frontend em Railway`

Opcionalmente:

`Servico Railway -> webhook n8n -> processamento -> banco -> callback para servico Railway`

Distribuicao de papeis sugerida:

- Railway hospeda a API principal, frontend, workers e, se fizer sentido, o n8n remoto
- n8n continua responsavel por ingestao, ETL, conciliacao, automacoes e integracoes
- Postgres continua sendo a SSOT, nao o canvas do workflow
- scripts externos podem atualizar workflows no n8n via API publica para evitar manutencao puramente manual no editor visual

Se o n8n continuar local e o restante for para Railway:

- o n8n local chama APIs no Railway por HTTP autenticado
- APIs no Railway podem disparar webhooks no n8n local ou remoto
- o banco pode ficar centralizado em Railway ou fora dele, desde que os acessos sejam segregados por credencial

Se tudo for para Railway:

- o storage de entrada precisa substituir a dependencia de pasta local montada
- em vez de `Documentos Bancarios/` por bind mount, usar bucket, volume persistente ou upload para API
- qualquer parser externo chamado por `child_process` no n8n precisa existir de forma empacotada na imagem do servico

## 4.5 API publica do n8n como mecanismo de manutencao

No projeto analisado, ha um padrao importante que vale portar:

- exportar ou buscar o workflow atual por script externo
- limpar propriedades invalidas do JSON exportado
- reenviar o workflow com `PUT /api/v1/workflows/:id`
- reativar o workflow apos atualizacao, quando necessario

Esse padrao transforma o workflow em um artefato parcialmente versionavel e reduz o risco de manutencao manual de nodes complexos.

Boas praticas para reaproveitar:

- nunca salvar API key real em repositario
- ler segredos de `.env` ou secret manager
- persistir o JSON limpo do workflow como artefato de referencia
- usar scripts para patches densos de nodes `Code`, queries SQL e ligacoes entre nodes
- registrar o `workflow_id`, objetivo do patch e evidencias de validacao

## 5. Contratos Minimos de Integracao

Para cada integracao, documentar no minimo:

- origem
- destino
- protocolo
- autenticacao
- payload de entrada
- payload de saida
- timeout
- retry
- comportamento em erro
- observabilidade

Checklist minimo:

| Item | Exigencia |
|---|---|
| Identidade da chamada | Quem chama quem |
| Exposicao | Publica ou interna |
| Autenticacao | API key, bearer, assinatura, mTLS ou equivalente |
| Idempotencia | Chave de deduplicacao ou correlation id |
| Persistencia | Onde o resultado e registrado |
| Falha | Retry, dead-letter ou log manual |
| Evidencia | Logs, execucoes do n8n, metricas, bugs_log |

Contrato adicional recomendado para fluxos n8n:

- `workflow_id` ou nome canonico do fluxo
- tipo de trigger: manual, webhook, cron ou chamada interna
- dependencia de filesystem, bucket, fila, banco ou API
- output esperado por etapa: raw, staging, consolidado ou payload de resposta

## 6. Padroes de Operacao e Observabilidade

### 6.1 Logs

Registrar:

- request id
- workflow id ou execution id
- service name
- status da chamada
- erro resumido

### 6.2 Correlation ID

Recomendado em:

- webhook para API
- API para worker
- n8n para banco ou callback

Objetivo:

- rastrear ponta a ponta a mesma operacao

### 6.3 Evidencia minima

Manter evidencia em:

- logs do servico
- logs/executions do n8n
- tracking DOC2.5
- bugs_log quando houver incidente ou validacao relevante

## 7. Guardrails de Seguranca

- nunca versionar tokens, API keys, strings de conexao ou segredos
- evitar endpoints publicos quando servico interno resolver
- separar credenciais por servico
- limitar permissoes do n8n no banco
- validar payloads recebidos antes de persistir ou encaminhar
- mascarar dados sensiveis em logs

Observacao importante:

O material de origem contem exemplos locais de API e automacao. Nesta portabilidade, esses detalhes foram abstratizados e nenhum segredo foi reaproveitado.

## 8. Padroes de Erro e Recuperacao

### Falhas comuns

- webhook indisponivel
- credencial invalida
- timeout entre servicos
- payload rejeitado por schema
- duplicidade em reprocessamento
- dependencia externa fora do ar
- volume ou path nao montado no container
- parser externo ausente ou indisponivel
- workflow atualizado por JSON invalido na API do n8n
- divergencia entre dado bruto, staging e camada consolidada

### Respostas recomendadas

- retry com limite
- persistencia de erro para reprocessamento
- idempotencia por chave externa
- dead-letter ou fila de falhas para alto volume
- registro do incidente em `tests/bugs_log.md`

## 9. Matrizes de Uso Rapido

### Quando usar Railway

| Cenario | Railway faz sentido? | Observacao |
|---|---|---|
| API principal | Sim | Bom para hospedar backend e endpoints |
| Worker/cron | Sim | Bom para jobs e servicos auxiliares |
| Banco gerenciado | Sim | Quando houver necessidade de persistencia |
| Automacao visual | Sim, opcional | Pode hospedar n8n ou apenas APIs |

### Quando usar n8n

| Cenario | n8n faz sentido? | Observacao |
|---|---|---|
| Webhooks e integracoes | Sim | Forte para orquestracao |
| ETL | Sim | Bom para pipelines e transformacoes |
| Regras centrais complexas de dominio | Com cautela | Melhor manter o nucleo em backend dedicado |
| Jobs agendados | Sim | Forte em schedule e fan-out |

### Quando introduzir outro servidor

| Tipo | Quando incluir |
|---|---|
| Redis | cache, locks, filas leves |
| Postgres | persistencia, auditoria, relatorios |
| Worker dedicado | tarefas pesadas ou demoradas |
| Reverse proxy/API gateway | consolidacao de entrada, TLS, roteamento |

## 10. Blueprint Generico para Novos Projetos

Sequencia recomendada:

1. Definir a fonte de verdade do dominio
2. Definir se o n8n sera orquestrador, integrador ou apenas ferramenta auxiliar
3. Definir o papel do Railway: hospedagem de API, n8n, banco, worker ou combinacao
4. Definir quais chamadas devem ser internas e quais precisam ser publicas
5. Definir autenticacao e estrategia de idempotencia
6. Definir observabilidade minima
7. Implantar primeiro o contrato, depois a infraestrutura, depois os fluxos

Blueprint mais aderente ao modelo observado:

1. Definir a origem de entrada: pasta local, upload HTTP, bucket ou fila
2. Definir o parser por tipo de arquivo ou payload
3. Criar camada `raw` para rastrear arquivo, hash, origem e timestamp
4. Criar camada `staging` para dados parseados ainda sem regra de negocio final
5. Criar camada canonica e views de consolidacao no banco
6. Definir se a categorizacao fica no banco, no n8n ou em servico dedicado
7. Expor consumo por API, webhook ou frontend separado
8. Automatizar manutencao dos workflows com export/import ou API publica do n8n

## 11. Decisoes Portaveis para Cindy OC

Estas diretrizes podem ser reaproveitadas em outros projetos do ecossistema Cindy:

- Railway como camada de servicos e hospedagem
- n8n como camada de orquestracao e automacao
- banco como trilha de auditoria e persistencia quando aplicavel
- DOC2.5 como camada de governanca e rastreabilidade

## 12. Pendencias de Validacao

- escolher em cada projeto se o n8n ficara dentro ou fora do Railway
- definir padrao oficial de autenticacao entre servicos do ecossistema
- definir quando usar fila em vez de chamadas HTTP diretas
- definir um modelo canonico de contrato entre workflow, API e worker
