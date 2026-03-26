# N8N Skills Index - Cline Runtime

**Last Updated**: March 2026 (Sprint S2)  
**Status**: 3 production-validated skills ported from KB/n8n-workflow-guide.md

## Skills Created/Updated

### 1. n8n-workflow-patterns
- **File**: `.cline/skills/n8n-workflow-patterns/SKILL.md`
- **Status**: ✓ Updated with Sprint S2 patterns
- **Source**: KB/n8n-workflow-guide.md (sections 1-5)
- **Covers**: 5 core patterns, architecture framework, data flows
- **Ported to**: `.agents/`, `.codex/`

### 2. n8n-workflow-deployment
- **File**: `.cline/skills/n8n-workflow-deployment/SKILL.md`
- **Status**: ✓ Created from deploy_workflow_secure.ps1
- **Source**: Sprint S2 Cindy-Telegram production deployment
- **Covers**: API-first deployment, credential security, PowerShell automation
- **Ported to**: `.agents/`, `.codex/`

### 3. n8n-node-configuration
- **File**: `.cline/skills/n8n-node-configuration/SKILL.md`
- **Status**: ✓ Updated with operation-aware patterns
- **Source**: Sprint S2 workflow validation
- **Covers**: Resource/operation mapping, field dependencies, progressive disclosure
- **Ported to**: `.agents/`, `.codex/`

---

## Integration Guide

These 3 skills work together:

1. **Start with n8n-workflow-patterns**
   - Understand workflow structure
   - Choose pattern for your use case
   - Plan data flow

2. **Use n8n-node-configuration**
   - Configure nodes for your pattern
   - Understand field dependencies
   - Validate node parameters

3. **Use n8n-workflow-deployment**
   - Deploy workflow via API
   - Manage credentials securely
   - Test and validate in production

---

## Reference Material

- KB/n8n-workflow-guide.md (570+ lines)
- Deploy_workflow_secure.ps1 (production script)
- Cindy-Telegram workflow ID: f0Nbq7BA3mPoxZvZ
- Dev_Tracking_S2.md (Sprint documentation)
- tests/bugs_log.md (6/6 tests passing)

---

## Context Budget

| Skill | Complexity | Tokens ~Avg |
|-------|-----------|------------|
| n8n-workflow-patterns | Advanced | 4-6K |
| n8n-workflow-deployment | Advanced | 3-5K |
| n8n-node-configuration | Advanced | 3-5K |
| **Combined** | - | **~10-16K** |

---

## Next Steps

- [ ] Use skills in `.cline/` with `use_skill` command
- [ ] Access ported versions in `.agents/` and `.codex/`
- [ ] Reference in workflow KB as needed
- [ ] Update as patterns evolve

---

**Repository**: https://github.com/scaixeta/cindy-oc.git  
**Sprint**: S2 (March 2026)
