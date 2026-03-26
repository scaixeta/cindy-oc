# N8N Skills Index - Codex Runtime

**Last Updated**: March 2026 (Sprint S2)  
**Status**: 3 production-validated skills ported from Cline

## Skills Ported

### 1. n8n-workflow-patterns
- **File**: `.codex/skills/n8n-workflow-patterns/SKILL.md`
- **Status**: ✓ Ported with code optimization
- **Original**: `.cline/skills/n8n-workflow-patterns/`
- **Covers**: 5 core patterns, selection guide, architecture framework

### 2. n8n-workflow-deployment
- **File**: `.codex/skills/n8n-workflow-deployment/SKILL.md`
- **Status**: ✓ Ported with code optimization
- **Original**: `.cline/skills/n8n-workflow-deployment/`
- **Covers**: API deployment, REST API, credential management, PowerShell

### 3. n8n-node-configuration
- **File**: `.codex/skills/n8n-node-configuration/SKILL.md`
- **Status**: ✓ Ported with code optimization
- **Original**: `.cline/skills/n8n-node-configuration/`
- **Covers**: Operation-aware configuration, patterns, best practices

---

## Porting Notes

All skills ported with:
- ✓ Code adapted for codex context
- ✓ Examples condensed
- ✓ Context budget optimized
- ✓ Cross-skill references maintained

---

## Validation Source

- Knowledge Base: KB/n8n-workflow-guide.md (570+ lines)
- Deployment Script: deploy_workflow_secure.ps1
- Production Workflow: Cindy-Telegram (ID: f0Nbq7BA3mPoxZvZ)
- Test Results: 6/6 passing (tests/bugs_log.md)
- Documentation: Dev_Tracking_S2.md

---

## Related

- Original knowledge base: KB/n8n-workflow-guide.md
- Deployment guide: KB/railway-n8n-server-communication-patterns.md
- Implementation examples: workflow_simple.json, workflow_rescue.json

---

**Repository**: https://github.com/scaixeta/cindy-oc.git  
**Sprint**: S2 (March 2026)  
**Status**: Production-ready
