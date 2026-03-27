/**
 * ==============================================================================
 * TELEGRAM LOCKDOWN SKILL (Cindy OC - S2)
 * Objetivo: Reforçar a segurança do Bot do Telegram via Allow-list de IDs.
 * ==============================================================================
 */

const ALLOWED_CHAT_IDS = process.env.ALLOWED_CHAT_IDS ? 
    process.env.ALLOWED_CHAT_IDS.split(',').map(id => id.trim()) : 
    [];

module.exports = {
  name: "telegram_lockdown",
  description: "Enforce chat identity check for all incoming messages.",
  
  /**
   * Middleware de interceptação.
   * @param {Object} message O objeto de mensagem recebido.
   * @param {Object} context Contexto de execução do OpenClaw.
   */
  async preProcess(message, context) {
    const chatId = message.from && message.from.id.toString();
    
    if (!chatId) {
      console.warn("[TELEGRAM-LOCKDOWN] Mensagem sem ID de remetente. Ignorando.");
      context.stopExecution = true;
      return;
    }

    if (!ALLOWED_CHAT_IDS.includes(chatId)) {
      console.error(`[TELEGRAM-LOCKDOWN] Acesso NÃO AUTORIZADO detectado: ${chatId}`);
      
      // Opcional: Notificar o usuário master sobre a tentativa
      // await context.notifyMaster(`Tentativa de acesso não autorizado pelo ID: ${chatId}`);

      context.stopExecution = true; // Interrompe o processamento da IA
      return {
        reply: "❌ Acesso Negado. Você não está na lista de usuários permitidos desta instância."
      };
    }

    console.log(`[TELEGRAM-LOCKDOWN] Acesso concedido para ID: ${chatId}`);
  }
};
