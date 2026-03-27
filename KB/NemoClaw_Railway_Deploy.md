# KB: NemoClaw na Railway (Implantação PaaS / Lockdown)

Este guia documenta o processo de adaptação do **NemoClaw** (Nvidia + OpenShell + OpenClaw) para o ambiente **Railway**, garantindo a manutenção dos protocolos de segurança e rastreabilidade da governança **DOC2.5**.

---

## 1. Estratégia de Isolamento PaaS

Em um VPS tradicional, o NemoClaw utiliza o OpenShell para criar sandboxes Docker. Em ambientes PaaS como o Railway, onde o próprio serviço já roda dentro de um contêiner isolado, a estratégia foi adaptada para o modelo **Singular Container Lockdown**.

*   **Host**: Railway Infrastructure.
*   **Sandbox Privada**: O próprio container do serviço Railway.
*   **Restrição**: Isolamento de rede garantido nativamente pelo Railway e opcionalmente reforçado pelo `openclaw gateway` interno.

---

## 2. Configuração de Variáveis de Ambiente

Para o funcionamento do NemoClaw na Railway, as seguintes variáveis devem estar configuradas no dashboard:

| Variável | Exemplo | Finalidade |
| :--- | :--- | :--- |
| `NVIDIA_API_KEY` | `nv-sk-...` | Chave de inferência (Obrigatória). |
| `TELEGRAM_BOT_TOKEN` | `8683504...` | Token do bot para Bridge. |
| `ALLOWED_CHAT_IDS` | `8687754084` | Lista de IDs permitidos (Lockdown). |
| `OPENCLAW_CONFIG_PATH` | `/openclaw/data` | Caminho persistente de dados. |

---

## 3. Estrutura do Deploy

### Dockerfile (`Dockerfile`)
Baseado em Ubuntu 22.04, instala as dependências necessárias e configura o ambiente para execução do `nemoclaw` em modo `standalone`.

### Entrypoint (`entrypoint.sh`)
Responsável por:
1. Validar segredos no startup.
2. Iniciar o Gateway na porta dinâmica enviada pelo Railway (`$PORT`).
3. Iniciar a Bridge de canais (ex: Telegram).

---

## 4. Persistência e Volumes

Para evitar a perda de "Skills" e contextos a cada novo build, recomenda-se configurar um **Railway Volume**:
- **Mount Path**: `/openclaw/data`
- **Tamanho**: 1GB a 5GB.

---

## 5. Protocolo de Verificação (DOC2.5)

Após o deploy, execute a validação no console do Railway:

```bash
# Verificar se as skills de segurança estão ativas
nemoclaw status --all

# Testar bloqueio de rede para sites não autorizados
curl -I https://google.com
```

**Resultado Esperado**: O acesso a sites externos não autorizados pela política de lockdown deve ser bloqueado ou redirecionado.

---

**Versão**: 1.0
**Status**: [Approved Plan]
**Tracking**: Sprint S2 (OpenClaw Phase 1)
