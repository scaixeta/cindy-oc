# N8N Skills Index - Agents Runtime

**Last Updated**: March 2026 (Sprint S2)  
**Status**: 3 production-validated skills ported from Cline

## Skills Ported

### 1. n8n-workflow-patterns
- **File**: `.agents/skills/n8n-workflow-patterns/SKILL.md`
- **Status**: ✓ Ported with code adaptation
- **Original**: `.cline/skills/n8n-workflow-patterns/`
- **Covers**: 5 core patterns, selection matrix, architecture framework

### 2. n8n-workflow-deployment
- **File**: `.agents/skills/n8n-workflow-deployment/SKILL.md`
- **Status**: ✓ Ported with code adaptation
- **Original**: `.cline/skills/n8n-workflow-deployment/`
- **Covers**: API-first deployment, REST calls, PowerShell automation

### 3. n8n-node-configuration
- **File**: `.agents/skills/n8n-node-configuration/SKILL.md`
- **Status**: ✓ Ported with code adaptation
- **Original**: `.cline/skills/n8n-node-configuration/`
- **Covers**: Operation-aware config, field dependencies, patterns

---

## Porting Strategy

All 3 skills ported from `.cline/` with:
- ✓ Code optimized for agent use
- ✓ Examples consolidated
- ✓ Context budget optimized (~10-16K combined)
- ✓ Cross-references maintained

---

## Usage Pattern

1. **Agents access via**: Import from `.agents/skills/`
2. **Interoperability**: Same structure as `.cline/` and `.codex/`
3. **Content**: Derived from Sprint S2 validation (Cindy-Telegram workflow)

---

## Validation

- Source: KB/n8n-workflow-guide.md + deploy_workflow_secure.ps1
- Tests: 6/6 passing (Sprint S2 tests/bugs_log.md)
- Production: Cindy-Telegram workflow (ID: f0Nbq7BA3mPoxZvZ)
- Status: ✓ Production-ready

---

**Repository**: https://github.com/scaixeta/cindy-oc.git  
**Sprint**: S2 (March 2026)
