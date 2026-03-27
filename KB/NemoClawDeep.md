# Auditoria e plano de execução do ecossistema NemoClaw para a Sprint S2 no projeto Cindy OC

[Unverified] Parte dos artefatos citados (por exemplo, `setup-vps.sh`, `configure-caddy.sh`, `openclaw-policy.yml`, `.env.openclaw`, `telegram-lockdown.js`, `walkthrough.md`) não foi disponibilizada aqui para inspeção direta. Eu não tenho acesso ao conteúdo desses arquivos nesta conversa, então não consigo atestar o que eles fazem “com certeza”. O que segue valida **o desenho técnico** e **os passos** com base em documentação oficial e repositórios oficiais, e aponta **onde o seu guia interno precisa ajuste** para ficar aderente ao que a NVIDIA e o OpenClaw publicam. fileciteturn0file0

## Contexto, evidências e objetivo da análise

O seu material descreve a implantação do ecossistema NemoClaw (Sprint S2) com postura **Lockdown by Default** e lista artefatos de automação (VPS + Caddy), política “deny-by-default” e um componente adicional de “lockdown” no Telegram. fileciteturn0file0

Há, porém, um ponto de consistência interna: o seu `Dev_Tracking_S2.md` marca a Sprint como **“Sprint ativa”** e os itens como **Doing/To‑Do**, com “pendente de validação”. Isso conflita com a mensagem de “concluída com sucesso” — pelo menos com as evidências presentes nos dois arquivos que recebi. fileciteturn0file1

Como fontes externas, esta análise se ancora principalmente em:
- **NVIDIA NemoClaw Developer Guide** (arquitetura, quickstart, políticas, Telegram, comandos). citeturn14view0turn23view0turn5view0turn19search4turn26view1  
- **NVIDIA OpenShell Developer Guide** (schema de policy, `policy set`, upload/download, fluxo de iteração). citeturn10view0turn7view1turn25view0  
- Repositórios oficiais no **entity["company","GitHub","code hosting platform"]**: NemoClaw, OpenShell e OpenClaw. citeturn3view2turn15view0turn3view3  
- **OpenClaw Docs** (Telegram allowlist, skills, CLI). citeturn13view2turn13view0turn31search0  

## O que a NVIDIA diz sobre NemoClaw e OpenShell e as implicações práticas

A NVIDIA posiciona NemoClaw como um **stack de referência** que coloca o OpenClaw dentro de um sandbox controlado pelo OpenShell, com governança por políticas declarativas para rede, filesystem, processo e roteamento de inferência. citeturn18search11turn23view0turn18search2

image_group{"layout":"carousel","aspect_ratio":"16:9","query":["NVIDIA NemoClaw OpenShell OpenClaw architecture diagram","NVIDIA OpenShell terminal UI screenshot","OpenClaw gateway diagram port 18789"],"num_per_query":1}

### Requisitos e instalação considerados “canônicos” pela NVIDIA

No guia oficial, NemoClaw está em **alpha / early preview** desde **16 de março de 2026**, com aviso explícito de mudanças potencialmente disruptivas em APIs, schemas e comportamento. Isso afeta diretamente sua estratégia de “plano de execução”: vale tratar versões, backups e validações como gates obrigatórios, porque o sistema ainda está estabilizando. citeturn14view0turn3view2

O quickstart recomenda (Linux) **Ubuntu 22.04+**, **Node.js 20+**, **npm 10+**, runtime de containers (Docker como caminho principal), e OpenShell instalado. citeturn14view0turn21search11  
A instalação “one‑liner” documentada é via script da NVIDIA (que depois roda o wizard de onboarding): citeturn14view0

### Arquitetura e “Lockdown by Default” no nível certo

O “como encaixa” que a NVIDIA descreve é:
- `nemoclaw` (plugin/CLI) → executa um blueprint versionado (Python) → orquestra gateway/sandbox/policy/inference via OpenShell CLI. citeturn23view0turn3view0  

No baseline, a rede é **deny‑by‑default**: o sandbox só alcança endpoints explicitamente permitidos; tentativas para destinos não listados são interceptadas e aparecem na interface TUI (`openshell term`) para revisão do operador. citeturn5view0turn3view1  
O baseline também estabelece isolamento de filesystem (ex.: read‑write em `/sandbox` e `/tmp`, read‑only em paths de sistema) e roda como usuário/grupo `sandbox`, com Landlock em modo “best effort” no baseline. citeturn5view0turn8view1turn7view1

### Políticas: o schema que o OpenShell espera e o comando correto

O schema oficial do OpenShell define `network_policies` como um **mapa de entradas**, e cada entrada deve declarar:
- `endpoints` (lista com `host`, `port`, e opcionalmente inspeção L7 com `protocol: rest` + `rules`)
- `binaries` (lista de executáveis autorizados a usar aqueles endpoints). citeturn7view1turn8view1

No workflow oficial de iteração:
1) puxe a policy atual (`openshell policy get <name> --full`)  
2) edite, evitando mexer em partes estáticas criando necessidade de recriação  
3) aplique com **nome do sandbox + flag de policy**: `openshell policy set <name> --policy <arquivo> --wait`. citeturn10view0turn15view0

Isso é relevante porque o seu KB mostra um comando e um formato de YAML que não batem com o schema e com o CLI do OpenShell (detalho na seção de divergências). fileciteturn0file0

### Telegram no NemoClaw segundo a NVIDIA

A NVIDIA documenta o Telegram como “bridge” gerenciada por `nemoclaw start`, habilitada ao setar `TELEGRAM_BOT_TOKEN`. Ela também documenta um controle adicional por allowlist via variável `ALLOWED_CHAT_IDS` (lista separada por vírgula). citeturn19search4turn26view1  
O mesmo `start` também sobe um túnel `cloudflared` para acesso externo, segundo o doc. citeturn19search4

Ponto crítico para o seu plano: existe um issue aberto reportando que o script do bridge (`scripts/telegram-bridge.js`) hardcodeia o nome do sandbox como `"nemoclaw"` e não lê `defaultSandbox` do config; com isso, se você nomear o sandbox como `cindy-sandbox`, há risco de o Telegram “subir” mas não encaminhar mensagens ao agente (falha silenciosa). O issue aponta workaround: nomear o sandbox `"nemoclaw"` ou ajustar o script. citeturn29view0

Além disso, há sinal de instabilidade recente em “merge de presets” criando YAML inválido no NemoClaw (issue aberto em 27 mar 2026). Isso afeta a escolha “aceitar presets no onboarding” sem validar o YAML final. citeturn22search6turn24search0

## O que o OpenClaw diz sobre gateway, Telegram e skills e como isso se encaixa no seu desenho

### Porta do gateway e impacto na sua escolha por Caddy

O repositório oficial do OpenClaw mostra o gateway padrão sendo iniciado em `--port 18789`. citeturn3view3  
Logo, a ideia do seu guia de fazer reverse proxy para `127.0.0.1:18789` faz sentido do ponto de vista do OpenClaw, desde que você mantenha o gateway bound apenas localmente e exponha externamente só via proxy/TLS (ou via `cloudflared`). citeturn3view3turn19search4

### Telegram allowlist no OpenClaw (camada “app”)

O OpenClaw documenta `dmPolicy` com padrões e o modo “allowlist” exige `allowFrom` com IDs numéricos; lista vazia é rejeitada na validação. Para bots pessoais, recomenda `dmPolicy: "allowlist"` com IDs explícitos para policy durável, em vez de depender de aprovações passadas. citeturn13view2turn13view3

Isso é importante porque, mesmo usando `ALLOWED_CHAT_IDS` do NemoClaw (bridge), o OpenClaw tem um mecanismo nativo de controle de quem pode falar com o bot no nível do gateway/canal. Em um desenho “defense-in-depth”, os dois controles podem coexistir, mas o OpenClaw é a referência para a semântica do canal. citeturn13view2turn13view3turn19search4

### Skills: onde vivem, como instalar e o que é “seguro” segundo o OpenClaw

O OpenClaw descreve skills como diretórios AgentSkills‑compatíveis e aborda:
- locais e precedência: `<workspace>/skills` (maior), `~/.openclaw/skills` (médio), bundled (menor)  
- comandos CLI: `openclaw skills install`, `openclaw skills list`, `openclaw skills check`, etc. citeturn13view0turn31search0turn31search1  

As “security notes” do OpenClaw são explícitas: tratar skills de terceiros como **código não confiável**, ler antes de habilitar e preferir execuções sandboxed para inputs e ferramentas mais arriscadas. citeturn13view0

## Conformidade do seu material S2 com a documentação oficial e ajustes necessários

Abaixo eu comparo o seu `NemoClaw_Install.md` e o que ele afirma com os pontos mais “load‑bearing” das docs oficiais.

### O que está alinhado

A descrição macro das camadas (Host → OpenShell sandbox → OpenClaw) está consistente com o “How NemoClaw Works”/arquitetura: NemoClaw orquestra via OpenShell e o OpenClaw roda dentro do sandbox. fileciteturn0file0 citeturn23view0turn5view0

O uso de `nemoclaw onboard` como passo central de bootstrap também está alinhado com o comando oficial e com a descrição do wizard (cria gateway, registra providers, cria sandbox). fileciteturn0file0 citeturn14view1turn21search13

A intenção do seu “deny‑by‑default + allowlist” está alinhada com o baseline do NemoClaw e a forma como o OpenShell intercepta tráfego fora da policy e expõe na TUI (`openshell term`). fileciteturn0file0 citeturn5view0turn3view1

### Onde o seu guia precisa ajuste para ficar aderente (e por quê)

| Item do seu KB | Situação | O que ajustar com base em fontes oficiais |
|---|---|---|
| Presets “npm, python, telegram” | Divergente | Nos docs do NemoClaw, os presets listados são `npm`, `pypi`, `telegram`, etc. Não existe preset “python”; o equivalente prático para deps Python é `pypi`. fileciteturn0file0 citeturn19search0turn5view0 |
| Exemplo de `openclaw-policy.yml` (lista com `endpoint`/`port`/`binaries`) | Divergente | O schema do OpenShell usa `network_policies` como **mapa**; cada entry tem `endpoints` (lista de objetos) e `binaries` (lista de objetos com `path`). Além disso, regras L7 são definidas via `protocol: rest` + `rules`. fileciteturn0file0 citeturn7view1turn8view1 |
| `openshell policy set cindy-sandbox openclaw/openclaw-policy.yml` | Divergente | O caminho documentado no OpenShell é `openshell policy set <name> --policy <file> --wait` (e o workflow recomendado inclui `policy get`/`policy list`). O seu comando pode falhar dependendo da versão do CLI. fileciteturn0file0 citeturn10view0turn15view0 |
| `openshell sandbox exec ...` para testar rede | Divergente | A doc do OpenShell não descreve `sandbox exec`. Ela descreve `sandbox connect` (sessão interativa) e enfatiza upload/download. O troubleshooting do DGX Spark reforça que `sandbox connect` é interativo e sugere upload/download para automação. Portanto, o teste de rede deve ser feito dentro de uma sessão `connect`. fileciteturn0file0 citeturn25view0turn21search1 |
| Nome do sandbox sugerido (`cindy-sandbox`) + Telegram via `nemoclaw start` | Risco alto (bug conhecido) | Há issue aberta relatando que o bridge do Telegram hardcodeia o sandbox `"nemoclaw"`; com nomes customizados, o bridge pode falhar silenciosamente. Workaround: nomear sandbox `"nemoclaw"` ou ajustar o script. Isso impacta diretamente seu passo “Telegram MVP”. fileciteturn0file0 citeturn29view0turn19search4 |
| “Reiniciar gateway com supervisorctl dentro do sandbox” | Indeterminado | Eu não consigo confirmar que o ambiente NemoClaw usa `supervisorctl` exposto ao usuário `sandbox` (e policies rejeitam root). O caminho documentado pelos guias oficiais é operar via `nemoclaw`/`openshell` e via comandos `openclaw` dentro do sandbox. fileciteturn0file0 citeturn14view0turn7view1turn25view0 |

Conclusão desta seção: o seu KB está **no rumo certo** na intenção e no fluxo “onboard → policy deny-by-default → TUI para aprovar → Telegram”, mas há divergências concretas em **schema de policy**, **CLI**, **presets**, e **um risco de integração Telegram por bug conhecido** (nome do sandbox). fileciteturn0file0 citeturn29view0turn10view0turn19search0

## Plano grande e descritivo para executar a implantação no VPS com alto grau de previsibilidade

A estrutura abaixo é pensada para manter o princípio “Lockdown by Default” ao mesmo tempo em que reduz falhas comuns de onboarding/Telegram/policy.

### Fase de preparação e pré‑flight do VPS

**Defina o modelo de exposição externa (escolha consciente):**
- Caminho A: usar `cloudflared` (subido por `nemoclaw start`) para acesso externo. Isso tende a exigir menos portas públicas e cria conexões outbound‑only de `cloudflared` até a rede da entity["company","Cloudflare","internet security company"]. citeturn19search4turn28search21  
- Caminho B: usar proxy reverso com entity["company","Caddy","web server project"] para expor a UI do OpenClaw com HTTPS público. Para HTTPS automático, o Caddy usa “Automatic HTTPS” e precisa de hostname (domínio) e normalmente de porta 80/443 acessíveis (ACME HTTP‑01 tenta 80). citeturn17search0turn17search2turn17search3  

O seu KB assume o caminho B (Caddy + 80/443/22). Isso é tecnicamente coerente, mas o caminho A existe e pode ser mais simples se domínio/DNS/ACME forem fricções. fileciteturn0file0 citeturn19search4turn28search21turn17search0

**Checklist mínimo do host (antes de rodar qualquer script):**
- RAM: se você estiver perto do mínimo (8 GB), a doc do NemoClaw descreve risco de OOM durante push/build (Docker + k3s + gateway) e sugere swap como workaround. citeturn14view0  
- Docker em execução e usuário com permissão. O OpenShell também ressalta que “Docker precisa estar rodando” antes de criar gateway/sandbox. citeturn25view1  
- Se o VPS for Ubuntu 24.04/cgroup v2, o próprio `nemoclaw onboard` faz preflight e pode exigir `"default-cgroupns-mode": "host"` no Docker; a doc de troubleshooting recomenda `sudo nemoclaw setup-spark` como fix automatizado nesses ambientes. citeturn30search0turn30search2turn26view1  

### Fase de instalação “baseline” (sem customizações ainda)

**Instale NemoClaw pelo mecanismo oficial antes de automatizar:**
- A doc oficial descreve `curl -fsSL https://www.nvidia.com/nemoclaw.sh | bash` como caminho principal (instala Node se necessário e roda onboarding). citeturn14view0turn21search11  
- Por o projeto estar em alpha e com issues recentes ligados a onboarding/presets, esse passo “manual primeiro” ajuda a separar falha do produto vs falha do seu script. citeturn14view0turn24search0  

**Onboarding (`nemoclaw onboard`) com decisões explícitas:**
- Nome do sandbox: deve seguir RFC1123 (lowercase, hífen, etc.). citeturn30search2turn14view1  
- Se o Telegram for requisito MVP imediato, considere fortemente o workaround do issue: **nomear o sandbox como `nemoclaw`** para reduzir o risco do bridge “silencioso” (até você confirmar que seu código/script já corrigiu isso). citeturn29view0turn19search4  
- Provider e credenciais: o wizard suporta NVIDIA Endpoints e outros provedores; credenciais ficam em `~/.nemoclaw/credentials.json` segundo a doc de comandos. citeturn14view1  

**Validação mínima ao final do onboarding (sem Telegram ainda):**
- `nemoclaw <nome> status` e `nemoclaw <nome> logs --follow` para checar saúde. citeturn3view1turn14view0turn14view1  
- `openshell sandbox list` e `openshell term` para confirmar que OpenShell está operacional e observável. citeturn25view0turn3view1  
- Entrar no sandbox e testar inferência local via CLI: a doc de monitoramento sugere `nemoclaw <name> connect` e depois `openclaw agent ...` dentro do sandbox para testar. citeturn3view1turn14view0  

### Fase de Telegram com controle de acesso

**Configurar o bot:**
- Criar bot no entity["organization","BotFather","telegram bot management"] e exportar `TELEGRAM_BOT_TOKEN`. Isso está na doc oficial do bridge. citeturn19search4  

**Subir serviços auxiliares:**
- `nemoclaw start` sobe Telegram bridge e `cloudflared` (de acordo com a doc). citeturn19search4turn26view1  

**Restringir acesso:**
- Use `ALLOWED_CHAT_IDS` para restringir quais chats podem interagir com o agente (nível do bridge), como a doc oficial descreve. citeturn19search4  
- Se você também usar o canal Telegram nativo do OpenClaw (quando aplicável), configure `dmPolicy: "allowlist"` + `allowFrom` com IDs numéricos (nível do gateway/canal). citeturn13view2turn13view3  

**Teste e diagnóstico:**
- Se mensagens não chegarem ao agente, suspeite primeiro do bug do sandbox name hardcoded (issue #445) antes de mexer em rede/policy. citeturn29view0  
- Use `openshell term`/logs para ver se há bloqueios de rede, mas lembre: o bridge pode falhar por lógica de roteamento (nome do sandbox), não por egress. citeturn3view1turn29view0  

### Fase de política “mínimo necessário” com workflow iterativo (sem “abrir a internet”)

**Comece do baseline e reduza, em vez de inventar schema:**
- O baseline mostrado no repositório oficial (`openclaw-sandbox.yaml`) exemplifica exatamente o formato aceito (mapa `network_policies`, endpoints com `host/port`, binaries com `path`, regras por método/path quando `protocol: rest`). citeturn8view1turn7view1  

**Aplique mudanças dinamicamente do jeito suportado:**
- Pull da policy ativa: `openshell policy get <name> --full > current-policy.yaml`  
- Ajuste apenas `network_policies` (parte dinâmica)  
- Push: `openshell policy set <name> --policy current-policy.yaml --wait`  
- Verificação: `openshell policy list <name>` e acompanhamento no `openshell term`. citeturn10view0turn15view0  

**Evite “aprovar e esquecer”:**
- A doc do NemoClaw enfatiza que aprovações dinâmicas e policy updates em runtime são **session‑only** e resetam quando o sandbox para; persistência exige editar o baseline e recriar via `nemoclaw onboard`. citeturn19search0turn5view0  

**Sobre presets:**
- O NemoClaw lista presets (`pypi`, `npm`, `telegram`, etc.) e também expõe comandos `nemoclaw <name> policy-add`/`policy-list`. citeturn26view1turn19search0  
- Como há issues recentes sobre merge/presets gerando YAML inválido, trate “aceitar presets automaticamente” como um passo que precisa verificação (por exemplo, validar a policy final via `openshell policy list` e observar se o proxy deixa o tráfego esperado). citeturn24search0turn22search6  

### Fase de skills com “supply chain awareness”

Você descreveu instalar skills “fora do sandbox” e copiar apenas após revisão. A intenção está alinhada com o alerta do OpenClaw de tratar skills de terceiros como código não confiável. fileciteturn0file0 citeturn13view0

Para operacionalizar isso com ferramentas suportadas:

- Inspecione e gerencie skills com o CLI oficial: `openclaw skills list`, `openclaw skills info`, `openclaw skills check`, e instale via `openclaw skills install <slug>`. citeturn31search0  
- Entenda onde skills podem residir e quem “vence” na precedência: `<workspace>/skills` e `~/.openclaw/skills` são os alvos clássicos. citeturn13view0turn31search1  
- Para copiar arquivos para dentro do sandbox (quando você decidir que um bundle é aceitável), use o mecanismo documentado do OpenShell: `openshell sandbox upload` / `openshell sandbox download`. citeturn25view0turn23view2  

Observação importante de compatibilidade com NemoClaw: o próprio baseline do NemoClaw comenta que `/sandbox/.openclaw` é tratado como “imutável” e que estado gravável vive em `/sandbox/.openclaw-data` via symlinks. Então, se você estiver copiando “na mão”, você deve descobrir **o path real** onde o OpenClaw está carregando skills e gravando estado no sandbox, em vez de assumir diretórios como `/openclaw/skills/`. O caminho “menos frágil” é usar `openclaw skills install` dentro do ambiente em que o gateway roda e então auditar o resultado com `openclaw skills list`/`info`. citeturn8view1turn31search0turn13view0  

### Fase de exposição HTTPS com Caddy (se você escolher esse caminho)

Se você seguir com Caddy (como seu KB propõe): fileciteturn0file0

- Confirme que o backend (OpenClaw gateway) está em `127.0.0.1:18789`. A porta 18789 aparece como padrão no quickstart do OpenClaw. citeturn3view3  
- O Caddy fornece HTTPS automático (“Automatic HTTPS”) e reverse proxy com `reverse_proxy`. Isso é documentado como comportamento padrão para hostnames válidos. citeturn17search0turn17search3turn17search4  
- Para ACME HTTP‑01 (o caso mais comum), port 80 precisa ser acessível externamente; isso aparece como restrição do padrão ACME. citeturn17search2turn17search12  

Do ponto de vista “Lockdown by Default”, isso implica manter:
- 80/443 expostos apenas no proxy reverso  
- gateway interno não exposto diretamente na interface pública  
- validação de que WebSocket/upgrade está funcionando (OpenClaw UI costuma usar conexões persistentes). (Eu não consigo validar sua config específica sem ver `configure-caddy.sh`.) fileciteturn0file0 citeturn17search3turn17search4  

## Critérios de aceite, validações de segurança e gate para iniciar a Fase 2

Para encerrar S2 com rastreabilidade “DOC2.5” (como seu tracking pede), eu sugiro critérios objetivos e auditáveis — sem depender de “parece que funcionou”. fileciteturn0file1

### Aceite operacional mínimo (MVP)

1) **Sandbox funcional e observável**  
`nemoclaw <name> status` saudável + logs acessíveis + `openshell term` mostrando sandbox e eventos. citeturn3view1turn26view1  

2) **Lockdown de rede comprovado**  
Dentro do sandbox (via `nemoclaw <name> connect`), uma tentativa de alcançar um host não allowlist deve ser bloqueada e refletida no TUI/logs, e a permissão deve ser obtida somente via policy/approval do operador. citeturn5view0turn3view1turn25view0  

3) **Lockdown de filesystem demonstrável**  
Provar que paths fora do escopo (ex.: `/home/...` do host) não estão acessíveis a partir do sandbox, conforme baseline (`/sandbox` e `/tmp` RW; resto RO/inelegível). citeturn5view0turn8view1  

4) **Telegram controlado por allowlist**  
`TELEGRAM_BOT_TOKEN` configurado, `nemoclaw start` ativo, e `ALLOWED_CHAT_IDS` limitando chats. Teste de “chat não autorizado” deve falhar. citeturn19search4turn26view1  
Se você optar por reforçar com allowlist do OpenClaw (`dmPolicy: "allowlist"` + `allowFrom`), valide também isso. citeturn13view2  

### Aceite de governança e continuidade

5) **Backup/restore validado** (antes de qualquer destroy/upgrade)  
Usar o procedimento oficial para baixar workspace files (SOUL/USER/IDENTITY/AGENTS/MEMORY + `memory/`) via `openshell sandbox download` e validar restauração via `openshell sandbox upload`. citeturn23view2turn23view1  

6) **Registro de versão/estado para reprodutibilidade**  
Capturar versões e estado (por exemplo: `nemoclaw list`, policy aplicada, presets aplicados) e registrar no `Dev_Tracking_S2.md` com timestamp, porque NemoClaw é alpha e updates podem mudar comportamento. citeturn14view1turn23view2turn14view0  

### Alertas de risco específicos para o seu plano

- Se você mantiver o nome do sandbox como `cindy-sandbox` e depender do Telegram bridge do NemoClaw, valide imediatamente se você não está no cenário do issue #445 (hardcode `"nemoclaw"`). Se estiver, você tem duas opções operacionais: renomear para `nemoclaw` no onboarding (workaround) ou ajustar o bridge script (mudança de código — exigiria governança de alteração). citeturn29view0  
- Trate “presets” como etapa que pode quebrar onboarding/policy merge (há issue recente de YAML inválido). Um caminho mais controlado é: aplicar baseline, observar bloqueios, iterar com `policy get/set` e só então consolidar no baseline + `nemoclaw onboard`. citeturn24search0turn10view0turn19search0  

Esses gates fecham o que você descreveu como Sprint S2 (“instalação, confirmação, configuração e lockdown”), mantendo o espírito do seu tracking: validações manuais registradas e sem avançar para “funcionalidades” antes da base estar validada. fileciteturn0file1