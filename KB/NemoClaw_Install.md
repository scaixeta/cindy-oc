# KB: Instalação e Segurança NemoClaw (Nvidia + OpenShell + OpenClaw)

Esta documentação consolida o guia de instalação prática, as diretrizes de endurecimento (hardening) de segurança e a configuração do ecossistema NemoClaw para o projeto **Cindy OC**.

> [!NOTE]
> Este guia é baseado nas demonstrações técnicas da **FuturMinds** e na implementação personalizada ("Lockdown by Default") realizada durante a Sprint S2.

---

## 1. Visão Geral da Arquitetura

O sistema NemoClaw opera em três camadas de isolamento:

1.  **Host**: Servidor Linux VPS onde residem os segredos (API Keys) e o orquestrador.
2.  **OpenShell (Sandbox)**: Ambiente de contêiner isolado que executa o agente. Controla permissões de rede e binários via políticas declarativas.
3.  **OpenClaw**: O agente de IA (Gateway) que interage com o usuário e ferramentas.

---

## 2. Preparação do Ambiente (Host)

### Requisitos de Rede (Firewall)
Libere as seguintes portas no painel do seu provedor (Hostinger/AWS/GCP):
*   **Porta 80 (TCP)**: HTTP (Caddy/Desafio ACME)
*   **Porta 443 (TCP)**: HTTPS (Dashboard Segura)
*   **Porta 22 (TCP)**: Acesso SSH

### Instalação Automática
Utilize o script `c:\Cindy-OC\scripts\setup-vps.sh` para preparar o host. Ele instala:
- Docker e Docker Compose
- OpenShell (Camada de Segurança)
- NemoClaw (CLI do Orquestrador)
- Caddy Server (Proxy Reverso)

```bash
# Execução no Host
chmod +x setup-vps.sh
./setup-vps.sh
```

---

## 3. Onboarding e Sandbox

Inicie o assistente de configuração local no host:
```bash
nemoclaw onboard
```
**Parâmetros recomendados:**
*   **Sandbox Name**: `cindy-sandbox`
*   **API Key**: Sua chave do build.nvidia.com (Nvidia Neotron).
*   **Presets**: Selecione apenas os básicos (`npm`, `python`, `telegram`).

---

## 4. Configuração do Gateway HTTPS (Caddy)

Para evitar o uso de portas expostas e garantir SSL, configure o Caddy utilizando o script `configure-caddy.sh`:

```bash
./scripts/configure-caddy.sh seu-subdominio.com
```

Isso criará um redirecionamento automático do tráfego HTTPS (443) para o gateway interno do OpenClaw na porta `18789`.

---

## 5. Endurecimento (Lockdown) de Rede

Por padrão, a Cindy segue a política **Deny-by-Default**.
Utilize o arquivo `c:\Cindy-OC\openclaw\openclaw-policy.yml` para definir as permissões explícitas.

```yaml
# Exemplo de Política (openclaw-policy.yml)
network_policies:
  - name: internal_inference
    endpoint: api.nvidia.com
    port: 443
    binaries: [openclaw]
  - name: telegram_bridge
    endpoint: api.telegram.org
    port: 443
    binaries: [openclaw]
```

**Aplicar política:**
```bash
openshell policy set cindy-sandbox openclaw/openclaw-policy.yml
```

---

## 6. Segurança de Skills (Lockdown de Chat)

A skill `telegram-lockdown.js` foi criada para impedir que usuários não autorizados utilizem o bot, mesmo que o token seja exposto.

**Arquivos:** `c:\Cindy-OC\openclaw\skills/telegram-lockdown.js`
**Instalação**: 
1. Mova o arquivo para `/openclaw/skills/` dentro do sandbox.
2. Reinicie o gateway: `supervisorctl restart openclaw-gateway` (dentro do sandbox).

---

## 7. Comandos Úteis de Verificação

| Ação | Comando |
| :--- | :--- |
| Monitorar Tráfego (TUI) | `openshell term` |
| Ver Logs do Sandbox | `openshell logs cindy-sandbox` |
| Testar Bloqueio de Rede | `openshell sandbox exec cindy-sandbox curl -I https://google.com` |
| Listar Sandboxes Ativos | `openshell sandbox list` |

---

## 8. Monitoramento via OpenShell TUI

O comando `openshell term` abre uma interface interativa onde você pode:
*   `L`: Ver Logs de tráfego em tempo real.
*   `R`: Ver Regras (Rules) e tentativas de bloqueio (em vermelho).
*   `A`: Aprovar temporariamente uma conexão bloqueada para depuração.

---

**Versão**: 1.0
**Status**: [Verified] por Antigravity (S2)
**Referências**: FuturMinds Video 1 & 2
