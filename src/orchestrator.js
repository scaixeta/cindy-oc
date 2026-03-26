// src/orchestrator.js
// Cindy AI Orchestrator - Core Engine
// DOC2.5 compliant routing and skills discovery

const fs = require('fs');
const path = require('path');

class CindyOrchestrator {
  constructor(config = {}) {
    this.mode = config.mode || process.env.ORCHESTRATOR_MODE || 'docker';
    this.governance = config.governance || process.env.DOC25_GOVERNANCE || 'enabled';
    this.skillsDiscovery = config.skillsDiscovery || process.env.SKILLS_DISCOVERY || 'auto';
    
    this.skills = new Map();
    this.kb = new Map();
    this.docs = new Map();
    this.routes = new Map();
    
    this.stats = {
      messages_processed: 0,
      errors_count: 0,
      uptime_start: Date.now()
    };
    
    console.log('[ORCHESTRATOR] Initializing Cindy Orchestrator');
    console.log(`[ORCHESTRATOR] Mode: ${this.mode}`);
    console.log(`[ORCHESTRATOR] Governance: ${this.governance}`);
    console.log(`[ORCHESTRATOR] Skills Discovery: ${this.skillsDiscovery}`);
  }

  /**
   * Initialize orchestrator: discover skills, KB, docs
   */
  async initialize() {
    console.log('[ORCHESTRATOR] Starting initialization...');
    
    if (this.skillsDiscovery === 'auto') {
      await this.discoverSkills();
      await this.discoverKB();
      await this.discoverDocs();
    }
    
    this.registerRoutes();
    
    console.log('[ORCHESTRATOR] ✅ Initialization complete');
    console.log(`[ORCHESTRATOR] Skills: ${this.skills.size}`);
    console.log(`[ORCHESTRATOR] KB entries: ${this.kb.size}`);
    console.log(`[ORCHESTRATOR] Docs: ${this.docs.size}`);
    console.log(`[ORCHESTRATOR] Routes: ${this.routes.size}`);
  }

  /**
   * Discover skills from .cline/skills directory
   */
  async discoverSkills() {
    const skillsIndexPath = path.join(__dirname, '../skills-index.json');
    
    if (fs.existsSync(skillsIndexPath)) {
      try {
        const data = JSON.parse(fs.readFileSync(skillsIndexPath, 'utf-8'));
        const skillNames = data.skills || [];
        
        skillNames.forEach(skillName => {
          if (skillName && skillName.trim()) {
            this.skills.set(skillName, {
              name: skillName,
              path: `.cline/skills/${skillName}`,
              discovered_at: new Date().toISOString()
            });
          }
        });
        
        console.log(`[DISCOVERY] Loaded ${this.skills.size} skills from index`);
      } catch (err) {
        console.error(`[DISCOVERY] Error loading skills index: ${err.message}`);
      }
    } else {
      console.log('[DISCOVERY] Skills index not found, skipping skill discovery');
    }
  }

  /**
   * Discover KB entries
   */
  async discoverKB() {
    const kbIndexPath = path.join(__dirname, '../kb-index.json');
    
    if (fs.existsSync(kbIndexPath)) {
      try {
        const data = JSON.parse(fs.readFileSync(kbIndexPath, 'utf-8'));
        const kbEntries = data.kb || [];
        
        kbEntries.forEach((entry, index) => {
          if (entry && entry.trim()) {
            const basename = path.basename(entry);
            this.kb.set(basename, {
              path: entry,
              discovered_at: new Date().toISOString()
            });
          }
        });
        
        console.log(`[DISCOVERY] Loaded ${this.kb.size} KB entries from index`);
      } catch (err) {
        console.error(`[DISCOVERY] Error loading KB index: ${err.message}`);
      }
    }
  }

  /**
   * Discover documentation files
   */
  async discoverDocs() {
    const docsIndexPath = path.join(__dirname, '../docs-index.json');
    
    if (fs.existsSync(docsIndexPath)) {
      try {
        const data = JSON.parse(fs.readFileSync(docsIndexPath, 'utf-8'));
        const docFiles = data.docs || [];
        
        docFiles.forEach((doc, index) => {
          if (doc && doc.trim()) {
            const basename = path.basename(doc);
            this.docs.set(basename, {
              path: doc,
              discovered_at: new Date().toISOString()
            });
          }
        });
        
        console.log(`[DISCOVERY] Loaded ${this.docs.size} documentation files from index`);
      } catch (err) {
        console.error(`[DISCOVERY] Error loading docs index: ${err.message}`);
      }
    }
  }

  /**
   * Register message routes
   */
  registerRoutes() {
    // Direct responses
    this.routes.set('/start', { type: 'direct', handler: 'handleStart' });
    this.routes.set('oi', { type: 'direct', handler: 'handleGreeting' });
    this.routes.set('olá', { type: 'direct', handler: 'handleGreeting' });
    
    // n8n routes
    this.routes.set('n8n:', { type: 'n8n', handler: 'handleN8n', prefix: true });
    
    // OpenClaw routes (future)
    this.routes.set('openclaw:', { type: 'openclaw', handler: 'handleOpenClaw', prefix: true });
    
    // Skills routes (future)
    this.routes.set('skill:', { type: 'skill', handler: 'handleSkill', prefix: true });
    
    console.log(`[ROUTES] Registered ${this.routes.size} routes`);
  }

  /**
   * Route incoming message
   */
  route(message) {
    const text = (message.text || '').toLowerCase().trim();
    
    // Check exact matches first
    if (this.routes.has(text)) {
      return this.routes.get(text);
    }
    
    // Check prefix matches
    for (const [key, route] of this.routes.entries()) {
      if (route.prefix && text.startsWith(key)) {
        return { ...route, matched: key };
      }
    }
    
    // Default fallback
    return { type: 'fallback', handler: 'handleFallback' };
  }

  /**
   * Process message through orchestrator
   */
  async processMessage(message) {
    this.stats.messages_processed++;
    
    const route = this.route(message);
    console.log(`[ORCHESTRATOR] Routing message to: ${route.type} (${route.handler})`);
    
    return {
      route: route.type,
      handler: route.handler,
      text: message.text,
      timestamp: new Date().toISOString()
    };
  }

  /**
   * Get orchestrator stats
   */
  getStats() {
    return {
      ...this.stats,
      uptime_seconds: Math.floor((Date.now() - this.stats.uptime_start) / 1000),
      skills_count: this.skills.size,
      kb_count: this.kb.size,
      docs_count: this.docs.size
    };
  }

  /**
   * Check governance compliance
   */
  checkGovernance(operation) {
    if (this.governance !== 'enabled') {
      return { compliant: true, reason: 'Governance disabled' };
    }
    
    // DOC2.5 governance rules
    const sensitiveOps = ['commit', 'push', 'delete', 'deploy'];
    
    if (sensitiveOps.includes(operation.type)) {
      console.log(`[GOVERNANCE] Sensitive operation detected: ${operation.type}`);
      return {
        compliant: false,
        reason: `Operation '${operation.type}' requires PO approval`,
        requires_approval: true
      };
    }
    
    return { compliant: true };
  }

  /**
   * Persist state to disk
   */
  async persistState() {
    const statePath = path.join(__dirname, '../state/orchestrator.json');
    
    const state = {
      mode: this.mode,
      governance: this.governance,
      stats: this.getStats(),
      last_updated: new Date().toISOString()
    };
    
    try {
      fs.writeFileSync(statePath, JSON.stringify(state, null, 2));
      console.log('[STATE] State persisted successfully');
    } catch (err) {
      console.error(`[STATE] Error persisting state: ${err.message}`);
      this.stats.errors_count++;
    }
  }
}

module.exports = CindyOrchestrator;
