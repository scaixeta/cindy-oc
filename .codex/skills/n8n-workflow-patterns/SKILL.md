---
name: n8n-workflow-patterns
description: Proven workflow architectural patterns from real n8n workflows. Use when building new workflows, designing workflow structure, choosing workflow patterns, planning workflow architecture, or asking about webhook processing, HTTP API integration, database operations, AI agent workflows, or scheduled tasks.
---

# n8n Workflow Patterns

Proven architectural patterns for building n8n workflows validated in production.

**Ported to**: `.codex/skills/n8n-workflow-patterns` (March 2026)
**Source**: Sprint S2 Cindy-Telegram production implementation
**Status**: Production-ready patterns

---

## The 5 Core Patterns

1. **Webhook Processing** (35%) - Receive → Process → Respond
2. **HTTP API Integration** (45%) - Fetch → Transform → Store
3. **Database Operations** (28%) - Query → Sync → Persist
4. **AI Agent Workflow** (emerging) - Trigger → AI Agent → Output
5. **Scheduled Tasks** (28%) - Cron → Process → Deliver

---

## Pattern Selection Guide

**Webhook Processing**: When receiving HTTP requests, building integrations
- Example: Form submission → Database → Slack notification

**HTTP API Integration**: When fetching from external APIs
- Example: GitHub issues → Jira tickets

**Database Operations**: When syncing between databases
- Example: Postgres → MySQL synchronization

**AI Agent Workflow**: When building conversational AI with tools
- Example: Chat with AI that can search docs, query DB

**Scheduled Tasks**: When running recurring automation
- Example: Daily report generation and email

---

## Workflow Architecture Framework

### Phase 1: Plan
- [ ] Identify trigger (webhook, schedule, manual)
- [ ] Identify data source (API, DB, file, service)
- [ ] Identify output (API, DB, notification, file)
- [ ] Plan error handling

### Phase 2: Design
- [ ] Map input → process → output
- [ ] Plan branching/conditional logic
- [ ] Plan error paths
- [ ] Document assumptions

### Phase 3: Implement
- [ ] Create trigger node
- [ ] Add data source nodes
- [ ] Configure authentication
- [ ] Add transformation nodes
- [ ] Add output nodes
- [ ] Configure error handling

### Phase 4: Validate
- [ ] Validate each node
- [ ] Validate complete workflow
- [ ] Test with sample data
- [ ] Handle edge cases

### Phase 5: Deploy
- [ ] Review settings
- [ ] Activate workflow
- [ ] Monitor executions
- [ ] Document in KB

---

## Core Data Flow Patterns

### Linear Flow
```
Trigger → Transform → Action → End
```
**Use**: Simple single-path workflows

### Branching Flow
```
Trigger → IF (condition) → [True Path]
                        → [False Path]
```
**Use**: Different actions based on conditions

### Parallel Processing
```
Trigger → [Branch 1] ├→ Merge → End
       └→ [Branch 2] ┘
```
**Use**: Independent operations running simultaneously

### Loop/Batch
```
Trigger → Split → Process → Loop Until Complete
```
**Use**: Processing large datasets in chunks

### Error Handling
```
Main Flow → [Success] → End
         → [Error] → Error Trigger → Alert/Retry
```
**Use**: Catching and handling errors gracefully

---

## Webhook Pattern (Most Common)

### Structure
```
Webhook (POST) → Validate → Transform → Respond
```

### Configuration
```json
{
  "nodes": [
    {
      "name": "Webhook",
      "type": "n8n-nodes-base.webhook",
      "parameters": {
        "httpMethod": "POST",
        "path": "cindy-telegram"
      }
    },
    {
      "name": "Respond",
      "type": "n8n-nodes-base.respondToWebhook",
      "parameters": {
        "responseBody": "{\"status\":\"received\"}"
      }
    }
  ]
}
```

### URL After Activation
```
POST http://127.0.0.1:5678/webhook/cindy-telegram
```

---

## HTTP API Pattern

### Structure
```
Trigger → HTTP Request → Transform → Action
```

### Implementation Checklist
- [ ] Create Trigger (Schedule or Manual)
- [ ] Create HTTP Request node
- [ ] Configure method (GET/POST)
- [ ] Configure URL + auth
- [ ] Add Set node for transformation
- [ ] Add action node (DB, Slack, etc)
- [ ] Add error handling

---

## Database Pattern

### Structure
```
Schedule → Query → Transform → Write → Verify
```

### Implementation Checklist
- [ ] Create Schedule trigger (cron)
- [ ] Create Database node
- [ ] Configure SELECT query
- [ ] Add Set node for transform
- [ ] Add INSERT/UPDATE node
- [ ] Verify with SELECT after write

---

## Common Workflow Gotchas

### 1. Webhook Data Structure
**Problem**: `{{$json.email}}` returns undefined
**Solution**: Data is nested under body: `{{$json.body.email}}`

### 2. Multiple Items Processing
**Problem**: Node processes all items, I only want one
**Solution**: Use `{{$json[0]}}` for first item or "Execute Once"

### 3. Authentication Failures
**Problem**: 401/403 errors on API calls
**Solution**: Use Credentials section, not parameters

### 4. Node Execution Order
**Problem**: Nodes executing in unexpected order
**Solution**: Check workflow settings → Execution Order

### 5. Expression Errors
**Problem**: `{{$json.field}}` shows as literal text
**Solution**: Ensure `{{}}` syntax and proper escaping

---

## Integration with Other Skills

**n8n-mcp-tools-expert** - Find nodes for your pattern
**n8n-node-configuration** - Configure operation-specific parameters
**n8n-validation-expert** - Validate workflow structure
**n8n-workflow-deployment** - Deploy workflow via API

---

## Real-World Examples

### Example 1: Form → Database → Slack
```
Webhook → IF (validate) → Postgres → Slack
```

### Example 2: Scheduled Data Sync
```
Schedule → HTTP → Set → MySQL → Email
```

### Example 3: Multi-API Parallel
```
Schedule ├→ HTTP API 1 ┤
       ├→ HTTP API 2 ├→ Merge → Transform → DB
       └→ HTTP API 3 ┘
```

### Example 4: Error Handling
```
Webhook → HTTP ├→ Respond (200)
            └→ Error Trigger → Slack Alert
```

---

## Best Practices

### ✅ Do
- Plan pattern before building
- Use simplest pattern that solves problem
- Implement error handling on all workflows
- Test with sample data
- Monitor executions after deployment
- Document workflow purpose
- Use descriptive node names
- Version control workflow JSON

### ❌ Don't
- Build without planning
- Skip validation
- Ignore error cases
- Over-engineer simple workflows
- Hardcode credentials
- Deploy untested
- Mix multiple patterns confusingly
- Forget to handle empty data

---

## Quick Reference

**Triggers**: Webhook, Schedule (Cron), Manual, Polling
**Data Sources**: HTTP, Database, Service nodes, Code
**Transformation**: Set, Code, IF, Switch, Merge
**Outputs**: HTTP, Database, Email, Slack, File
**Error Handling**: Error Trigger, IF conditions, Continue On Fail

---

**Last Updated**: March 2026 (Sprint S2)  
**Status**: Production-ready patterns
