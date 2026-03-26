// telegram-bot.js - Cindy OC Telegram Bot MVP (Hardened)
// Long polling loop with resilience and observability

require('dotenv').config({ path: '.scr/.env' });

// ============================================
// Startup Confirmation (ST-S1-06)
// ============================================
const STARTUP_TIME = new Date().toISOString();
console.log('========================================');
console.log('Cindy OC - Telegram Bot MVP');
console.log(`Startup: ${STARTUP_TIME}`);
console.log('========================================');

const TOKEN = process.env.TELEGRAM_BOT_TOKEN;
const N8N_URL = process.env.N8N_URL || 'https://n8n-runtime-production.up.railway.app';
const N8N_WEBHOOK_PATH = process.env.N8N_WEBHOOK_PATH || 'cindy-telegram';
const TIMEOUT_MS = 10000;
const MAX_RETRIES = 3;
const RETRY_DELAY_MS = 1000;

if (!TOKEN) {
  console.error('[FATAL] TELEGRAM_BOT_TOKEN not defined in .scr/.env');
  process.exit(1);
}

const API_URL = `https://api.telegram.org/bot${TOKEN}`;

let lastUpdateId = 0;
let messagesProcessed = 0;
let errorsCount = 0;

// ============================================
// ST-S1-15: Explicit Dispatcher
// ============================================
function routeMessage(text) {
  // Normal messages - /start
  if (text === '/start') {
    return { response: 'Olá, sou a Cindy uma IA da Sentivis. Posso te ajudar?', type: 'direct' };
  }
  
  // Greeting
  if (text.toLowerCase() === 'oi' || text.toLowerCase() === 'olá') {
    return { response: 'Olá, sou a Cindy uma IA da Sentivis. Posso te ajudar?', type: 'direct' };
  }
  
  // n8n: prefix - route to n8n
  if (text.toLowerCase().startsWith('n8n:')) {
    const n8nText = text.substring(4).trim();
    return { response: n8nText, type: 'n8n' };
  }
  
  // openclaw: prefix - placeholder
  if (text.toLowerCase().startsWith('openclaw:')) {
    console.log('[OPENCLAW PLACEHOLDER] Prefix detected, awaiting implementation');
    return { response: 'OpenClaw em preparacao. Use prefixo n8n: para automate simples.', type: 'openclaw' };
  }
  
  // Default fallback
  return { response: `Mensagem recebida: ${text}`, type: 'direct' };
}

// ============================================
// ST-S1-16: Operational Fallback
// ============================================
async function handleFallback(chatId, errorType) {
  let message = 'Servico temporariamente indisponivel';
  
  if (errorType === 'timeout') {
    message = 'Servico n8n excedeu o tempo de resposta (10s). Tente novamente.';
    console.error('[FALLBACK TIMEOUT] n8n response timeout');
  } else if (errorType === 'network' || errorType === 'http') {
    message = 'Erro ao processar requisicao. Tente novamente.';
    console.error('[FALLBACK ERROR] n8n request failed');
  } else if (errorType === 'openclaw') {
    message = 'OpenClaw em preparacao. Use prefixo n8n: para automate simples.';
    console.log('[FALLBACK OPENCLAW] Placeholder response');
  } else {
    message = 'Servico temporariamente indisponivel';
    console.error('[FALLBACK UNKNOWN] Unknown error type');
  }
  
  const sent = await sendMessage(message, chatId);
  console.log(sent ? `[OUTGOING FALLBACK] ${message}` : '[OUTGOING FALLBACK FAILED]');
  return sent;
}

async function getUpdates() {
  try {
    const url = `${API_URL}/getUpdates?offset=${lastUpdateId + 1}&timeout=1&limit=1`;
    const response = await fetch(url, { method: 'POST' });
    const data = await response.json();
    return data.ok ? data.result : [];
  } catch (err) {
    console.error(`[GETUPDATES ERROR] ${err.message}`);
    errorsCount++;
    return [];
  }
}

async function sendMessageWithRetry(text, chatId, retries = MAX_RETRIES) {
  for (let attempt = 1; attempt <= retries; attempt++) {
    try {
      const response = await fetch(`${API_URL}/sendMessage`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ chat_id: chatId, text: text })
      });
      const data = await response.json();
      if (data.ok) return true;
      console.error(`[SEND MESSAGE] Attempt ${attempt} failed: ${data.description}`);
    } catch (err) {
      console.error(`[SEND MESSAGE ERROR] Attempt ${attempt}: ${err.message}`);
    }
    if (attempt < retries) await new Promise(r => setTimeout(r, RETRY_DELAY_MS));
  }
  errorsCount++;
  return false;
}

const sendMessage = sendMessageWithRetry;

// Call n8n with timeout
async function callN8n(chatId, text) {
  const payload = { chat_id: chatId, text: text, source: 'telegram', timestamp: new Date().toISOString() };
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), TIMEOUT_MS);

  try {
    const response = await fetch(`${N8N_URL}/webhook/${N8N_WEBHOOK_PATH}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
      signal: controller.signal
    });
    clearTimeout(timeoutId);
    if (response.ok) {
      const data = await response.json();
      return data.text || data.message || null;
    }
    return { error: 'http', status: response.status };
  } catch (err) {
    clearTimeout(timeoutId);
    if (err.name === 'AbortError') {
      console.error('[N8N TIMEOUT] Exceeded 10s');
      return { error: 'timeout' };
    }
    console.error(`[N8N ERROR] ${err.message}`);
    return { error: 'network', message: err.message };
  }
}

function processMessage(update) {
  if (!update.message) return null;
  const msg = update.message;
  const chatId = msg.chat.id;
  const text = msg.text || '';
  const routed = routeMessage(text);
  return { chatId, response: routed.response, type: routed.type, raw: text };
}

async function handleMessage(update) {
  const result = processMessage(update);
  if (!result) return;

  console.log(`[INCOMING] ${result.raw}`);
  console.log(`[TYPE] ${result.type}`);

  if (result.type === 'n8n') {
    const n8nResponse = await callN8n(result.chatId, result.response);
    if (n8nResponse && typeof n8nResponse === 'string') {
      const sent = await sendMessage(n8nResponse, result.chatId);
      console.log(sent ? `[OUTGOING N8N] ${n8nResponse}` : '[OUTGOING N8N FAILED]');
    } else {
      const errorType = n8nResponse?.error || 'unknown';
      await handleFallback(result.chatId, errorType);
    }
  } else if (result.type === 'openclaw') {
    const sent = await sendMessage(result.response, result.chatId);
    console.log(sent ? `[OUTGOING OPENCLAW] ${result.response}` : '[OUTGOING OPENCLAW FAILED]');
  } else {
    const sent = await sendMessage(result.response, result.chatId);
    console.log(sent ? `[OUTGOING DIRECT] ${result.response}` : '[OUTGOING DIRECT FAILED]');
  }
  
  messagesProcessed++;
  console.log(`[STATS] Messages: ${messagesProcessed}, Errors: ${errorsCount}`);
}

async function main() {
  console.log('[INIT] Token loaded:', TOKEN ? 'YES' : 'NO');
  console.log('[INIT] n8n URL:', N8N_URL);
  console.log('[INIT] n8n webhook path:', N8N_WEBHOOK_PATH);
  console.log('[INIT] Timeout:', TIMEOUT_MS, 'ms');
  console.log('[INIT] Max retries:', MAX_RETRIES);
  console.log('[STATUS] Bot ready and listening...');
  
  while (true) {
    const updates = await getUpdates();
    for (const update of updates) {
      if (update.update_id <= lastUpdateId) continue;
      lastUpdateId = update.update_id;
      await handleMessage(update);
    }
    await new Promise(r => setTimeout(r, 500));
  }
}

main().catch(err => {
  console.error(`[FATAL] ${err.message}`);
  process.exit(1);
});