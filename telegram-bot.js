// telegram-bot.js - Minimal Telegram Bot MVP
// Long polling loop for receiving and responding to messages

const TOKEN = process.env.TELEGRAM_BOT_TOKEN;
const N8N_URL = process.env.N8N_URL || 'https://n8n-runtime-production.up.railway.app';
const N8N_WEBHOOK_PATH = process.env.N8N_WEBHOOK_PATH || 'cindy-telegram';
const TIMEOUT_MS = 10000;

if (!TOKEN) {
  console.error('TELEGRAM_BOT_TOKEN not defined in .scr/.env');
  process.exit(1);
}

const API_URL = `https://api.telegram.org/bot${TOKEN}`;

let lastUpdateId = 0;

async function getUpdates() {
  try {
    const url = `${API_URL}/getUpdates?timeout=1&limit=1`;
    const response = await fetch(url, { method: 'POST' });
    const data = await response.json();
    return data.ok ? data.result : [];
  } catch (err) {
    console.error('Error fetching updates:', err.message);
    return [];
  }
}

async function sendMessage(text, chatId) {
  try {
    const response = await fetch(`${API_URL}/sendMessage`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        chat_id: chatId,
        text: text
      })
    });
    const data = await response.json();
    return data.ok;
  } catch (err) {
    console.error('Error sending message:', err.message);
    return false;
  }
}

// Call n8n with timeout - per contract
async function callN8n(chatId, text) {
  const payload = {
    chat_id: chatId,
    text: text,
    source: 'telegram',
    timestamp: new Date().toISOString()
  };

  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), TIMEOUT_MS);

  try {
    const response = await fetch(`${N8N_URL}/webhook/${N8N_WEBHOOK_PATH}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(payload),
      signal: controller.signal
    });

    clearTimeout(timeoutId);

    if (response.ok) {
      const data = await response.json();
      return data.text || data.message || null;
    }
    return null;
  } catch (err) {
    clearTimeout(timeoutId);
    if (err.name === 'AbortError') {
      console.error('n8n timeout');
      return null;
    }
    console.error('n8n error:', err.message);
    return null;
  }
}

function processMessage(update) {
  if (!update.message) return null;
  
  const msg = update.message;
  const chatId = msg.chat.id;
  const text = msg.text || '';
  
  // /start command
  if (text === '/start') {
    return { chatId, response: 'Olá, sou a Cindy uma IA da Sentivis. Posso te ajudar?', type: 'direct' };
  }
  
  // greeting
  if (text.toLowerCase() === 'oi' || text.toLowerCase() === 'olá') {
    return { chatId, response: 'Olá, sou a Cindy uma IA da Sentivis. Posso te ajudar?', type: 'direct' };
  }
  
  // n8n: prefix - route to n8n
  if (text.toLowerCase().startsWith('n8n:')) {
    const n8nText = text.substring(4).trim();
    return { chatId, response: n8nText, type: 'n8n' };
  }
  
  // default fallback
  return { chatId, response: `Mensagem recebida: ${text}`, type: 'direct' };
}

async function handleMessage(update) {
  const result = processMessage(update);
  if (!result) return;

  console.log(`Message received: ${update.message.text}`);
  console.log(`Type: ${result.type}`);

  if (result.type === 'n8n') {
    // Call n8n with timeout per contract
    const n8nResponse = await callN8n(result.chatId, result.response);
    
    if (n8nResponse) {
      await sendMessage(n8nResponse, result.chatId);
      console.log(`n8n response sent: ${n8nResponse}`);
    } else {
      await sendMessage('Servico temporariamente indisponivel', result.chatId);
      console.log('Fallback sent: Servico temporariamente indisponivel');
    }
  } else {
    // Direct response
    await sendMessage(result.response, result.chatId);
    console.log(`Direct response sent: ${result.response}`);
  }
}

async function main() {
  console.log('Telegram Bot MVP started...');
  console.log(`Token: ${TOKEN ? 'loaded' : 'MISSING'}`);
  console.log(`n8n: ${N8N_URL}`);
  console.log(`n8n webhook path: ${N8N_WEBHOOK_PATH}`);
  console.log(`Timeout: ${TIMEOUT_MS}ms`);
  
  while (true) {
    const updates = await getUpdates();
    
    for (const update of updates) {
      if (update.update_id <= lastUpdateId) continue;
      lastUpdateId = update.update_id;
      await handleMessage(update);
    }
    
    // Small delay to avoid rate limiting
    await new Promise(r => setTimeout(r, 500));
  }
}

main().catch(err => {
  console.error('Fatal error:', err);
  process.exit(1);
});
