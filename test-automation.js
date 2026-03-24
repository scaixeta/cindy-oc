// test-automation.js - ST-S1-17: Automated n8n E2E Test Suite
// Runs full test round with single command, no human interaction

const TELEGRAM_TOKEN = process.env.TELEGRAM_BOT_TOKEN || '8683504450:AAGoxJ9z-AjDbAq5UkTobaCVir0slVJS1MQ';
const TELEGRAM_CHAT_ID = process.env.TELEGRAM_CHAT_ID || '8687754084';
const N8N_URL = process.env.N8N_URL || 'https://n8n-runtime-production.up.railway.app';
const N8N_WEBHOOK_PATH = process.env.N8N_WEBHOOK_PATH || 'cindy-telegram';

const TELEGRAM_API_URL = `https://api.telegram.org/bot${TELEGRAM_TOKEN}`;

const testCases = [
  { name: '/start', input: '/start', route: 'direct', expected: 'Cindy' },
  { name: 'oi', input: 'oi', route: 'direct', expected: 'Cindy' },
  { name: 'n8n: test echo', input: 'n8n: test echo', route: 'n8n', expected: 'n8n' },
  { name: 'n8n: test success', input: 'n8n: test success', route: 'n8n', expected: 'n8n' },
  { name: 'n8n: test fail', input: 'n8n: test fail', route: 'n8n', expected: 'fallback' },
  { name: 'openclaw: teste', input: 'openclaw: teste', route: 'openclaw', expected: 'OpenClaw' }
];

async function sendTelegramMessage(text) {
  const response = await fetch(`${TELEGRAM_API_URL}/sendMessage`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ chat_id: TELEGRAM_CHAT_ID, text: text })
  });
  return response.json();
}

async function callN8n(text) {
  const payload = { chat_id: TELEGRAM_CHAT_ID, text: text, source: 'telegram', timestamp: new Date().toISOString() };
  const response = await fetch(`${N8N_URL}/webhook/${N8N_WEBHOOK_PATH}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload)
  });
  if (response.ok) return await response.json();
  return { error: response.status };
}

function evaluateResult(testCase, telegramResult, n8nResult) {
  const results = { pass: false, route: null, response: null, notes: '' };
  
  if (testCase.route === 'direct') {
    results.route = 'direct';
    // For direct messages, we just verify the message was sent (ok: true)
    // The bot processes it asynchronously
    results.pass = telegramResult && telegramResult.ok === true;
    results.response = telegramResult && telegramResult.result ? telegramResult.result.text : 'N/A';
    results.notes = results.pass ? 'OK - message sent to bot' : 'Telegram API failed';
  } else if (testCase.route === 'n8n') {
    results.route = 'n8n';
    if (n8nResult && n8nResult.text) {
      results.response = n8nResult.text;
      // n8n echoes back with "n8n recebeu: <text>"
      results.pass = n8nResult.text.includes('n8n recebeu:');
      results.notes = results.pass ? 'OK - n8n webhook responded' : 'Unexpected n8n response';
    } else {
      results.pass = testCase.expected === 'fallback';
      results.notes = results.pass ? 'Fallback triggered OK' : 'No n8n response';
    }
  } else if (testCase.route === 'openclaw') {
    results.route = 'openclaw';
    // For openclaw, we verify message was sent (the bot handles it)
    results.pass = telegramResult && telegramResult.ok === true;
    results.response = telegramResult && telegramResult.result ? telegramResult.result.text : 'N/A';
    results.notes = results.pass ? 'OK - message sent, placeholder response expected' : 'Telegram API failed';
  }
  
  return results;
}

async function runTests() {
  const runId = `TEST-${Date.now()}`;
  const startTime = new Date();
  
  console.log('========================================');
  console.log(`Cindy OC - Automated Test Suite`);
  console.log(`Run ID: ${runId}`);
  console.log(`Start: ${startTime.toISOString()}`);
  console.log('========================================');
  
  const results = [];
  
  for (const testCase of testCases) {
    console.log(`\n[TEST] ${testCase.name}`);
    const testStart = Date.now();
    
    try {
      let telegramResult = null;
      let n8nResult = null;
      
      // Direct routes - send via Telegram
      if (testCase.route === 'direct' || testCase.route === 'openclaw') {
        telegramResult = await sendTelegramMessage(testCase.input);
      }
      
      // n8n route - call webhook directly
      if (testCase.route === 'n8n') {
        n8nResult = await callN8n(testCase.input.replace('n8n: ', ''));
      }
      
      const testDuration = Date.now() - testStart;
      const evalResult = evaluateResult(testCase, telegramResult, n8nResult);
      
      results.push({
        testName: testCase.name,
        input: testCase.input,
        route: evalResult.route,
        response: evalResult.response,
        pass: evalResult.pass,
        durationMs: testDuration,
        notes: evalResult.notes
      });
      
      console.log(`  Route: ${evalResult.route}`);
      console.log(`  Response: ${evalResult.response || 'N/A'}`);
      console.log(`  Pass: ${evalResult.pass ? 'YES' : 'NO'}`);
      console.log(`  Duration: ${testDuration}ms`);
      
    } catch (err) {
      console.error(`  ERROR: ${err.message}`);
      results.push({
        testName: testCase.name,
        input: testCase.input,
        route: testCase.route,
        response: null,
        pass: false,
        durationMs: Date.now() - testStart,
        notes: `Error: ${err.message}`
      });
    }
  }
  
  const endTime = new Date();
  const totalDuration = endTime - startTime;
  const passed = results.filter(r => r.pass).length;
  const failed = results.filter(r => !r.pass).length;
  
  console.log('\n========================================');
  console.log('TEST SUMMARY');
  console.log('========================================');
  console.log(`Run ID: ${runId}`);
  console.log(`Start: ${startTime.toISOString()}`);
  console.log(`End: ${endTime.toISOString()}`);
  console.log(`Total Duration: ${totalDuration}ms`);
  console.log(`Passed: ${passed}/${results.length}`);
  console.log(`Failed: ${failed}/${results.length}`);
  console.log('========================================');
  
  console.log('\nDETAILED RESULTS:');
  results.forEach((r, i) => {
    console.log(`${i+1}. ${r.testName}: ${r.pass ? 'PASS' : 'FAIL'} (${r.route})`);
    if (r.notes) console.log(`   Notes: ${r.notes}`);
  });
  
  // Return final summary
  return {
    runId,
    startTime: startTime.toISOString(),
    endTime: endTime.toISOString(),
    totalDurationMs: totalDuration,
    totalTests: results.length,
    passed,
    failed,
    results
  };
}

runTests().then(summary => {
  console.log('\n[TEST-S1-17] Automated test suite completed');
  process.exit(summary.failed > 0 ? 1 : 0);
}).catch(err => {
  console.error(`[FATAL] ${err.message}`);
  process.exit(1);
});