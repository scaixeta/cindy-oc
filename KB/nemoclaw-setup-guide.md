# nemoclaw-setup-guide

Setup Guide · March 2026

NemoClaw on Hostinger VPS

A non-technical guide — from zero to running AI agent with Claude

nemoclaw v0.1.0 · OpenClaw 2026.3.11 · Ubuntu 24.04

# 01  Before you start

You need four things before running any commands:

# 02  Open the firewall in Hostinger hPanel

Hostinger drops all incoming traffic by default. Add two rules before anything else.

In hPanel, select your VPS → click Security → click Firewall → select your server → click Manage.

Click Add rule: Action = Accept · Protocol = TCP · Port = 80 · Source = Any. Click Add rule.

Repeat with Port = 443. Everything else stays the same.

# 03  Install NemoClaw

Three commands — run them in order. Each one builds on the last.

Ubuntu 24.04 uses cgroup v2 which requires a Docker config fix. This also installs the OpenShell CLI.

Node.js is handled automatically — you don't need to install it separately. The first two lines ensure nvm is loaded before the script runs.

After install, nemoclaw and openshell may not be found in new terminal sessions. Run this once to fix it permanently:

# 04  Complete the setup wizard

The install script from Step C launches the wizard automatically. If it doesn't — or if you need to re-run it — start it manually:

The wizard runs through 7 stages and asks for your input at three points:

The wizard shows:

Type nemoclaw-sandbox and press Enter. If it says "already exists — Recreate? [y/N]", press N to keep the existing one.

The wizard shows:

Paste your nvapi-... key and press Enter.

Near the end the wizard asks:

Type list and press Enter, then type slack,telegram and press Enter.

When the wizard finishes you'll see a summary. Now connect to start the OpenClaw gateway and port forward:

Wait for the sandbox prompt (sandbox@nemoclaw-sandbox). This means OpenClaw is running and the port forward on 127.0.0.1:18789 is active. Keep this session running and open a new terminal for remaining steps.

# 05  Find and save your gateway token

The gateway token is your password to log into the chat interface. Get it reliably by connecting to the sandbox and reading the config file:

# 06  Set up Caddy for HTTPS access

Caddy gives you a clean https:// address with an auto-renewing SSL certificate. No port numbers in your URL, nothing to manage manually.

In hPanel, go to your VPS Overview page. Your subdomain looks like srv1234567.hstgr.cloud. Copy it — you need it in the next step.

Replace YOUR-SUBDOMAIN.hstgr.cloud with your actual subdomain, then run both commands:

# 07  Access the chat interface

Before opening the browser, confirm the gateway is active:

Port 18789 should show as listening and the forward status should be running. If it shows dead or nothing appears, run:

Wait for the sandbox prompt to appear. The forward starts automatically. You only need to run this once — it keeps running even after you exit the terminal session.

Open your browser and go to:

You'll see the OpenClaw login screen. Enter the gateway token you saved in Section 05.

# 08  Add your API keys securely

OpenShell manages API keys as providers — named credential bundles stored on the VPS host and injected into sandboxes at runtime. Keys never touch the sandbox filesystem. OpenClaw sends all inference requests through inference.local, a special endpoint where OpenShell's privacy router strips sandbox-side credentials, injects the real key from the host, and forwards to the actual API.

Run on the VPS host — not inside the sandbox. Replace the key values with your real keys.

OpenShell routes keys securely via inference.local, but OpenClaw also needs to know about the providers in its own config. Run this script outside the sandbox:

Then, inside the sandbox:

Still inside the sandbox, stop and restart the OpenClaw gateway:

Then exit the sandbox:

In the chat UI, go to Settings → Models — you should now see Anthropic and OpenAI listed as providers. GPT-4.1 will be the default.

# 09  Quick command cheatsheet

All commands run on the VPS host — not inside the sandbox.

NemoClaw alpha · March 2026 · FuturMinds