---
name: n8n-workflow-patterns
description: Proven workflow architectural patterns from real n8n workflows. Use when building new workflows, designing workflow structure, choosing workflow patterns, planning workflow architecture, or asking about webhook processing, HTTP API integration, database operations, AI agent workflows, or scheduled tasks.
---

# n8n Workflow Patterns

Proven architectural patterns for building n8n workflows based on real Sprint S2 validation.

**Ported from**: `.cline/skills/n8n-workflow-patterns` (March 2026)
**Status**: Production-validated with Cindy-Telegram workflow

---

## The 5 Core Patterns

1. **Webhook Processing** - Receive → Process → Respond (35% of workflows)
2. **HTTP API Integration** - Fetch → Transform → Store (45% of workflows)
3. **Database Operations** - Query → Sync → Persist (28% of workflows)
4. **AI Agent Workflow** - Trigger → AI Agent → Output (emerging pattern)
5. **Scheduled Tasks** - Cron → Process → Deliver (28% of workflows)

---

## Pattern Selection Matrix

| Pattern | Trigger | Use Case | Example |
|---------|---------|----------|---------|
| **Webhook** | HTTP POST | Real-time events | Stripe webhook → DB update |
| **HTTP API** | Schedule/Manual | Data fetching | GitHub issues → Jira |
| **Database** | Schedule/Webhook | Data sync | Postgres → MySQL |
| **AI Agent** | Webhook/Manual | Conversational AI | Chat + tool access |
| **Scheduled** | Cron | Reports/maintenance | Daily analytics email |

---

## Workflow Architecture Framework

### Phase 1: Plan (Pattern Selection)
- [ ] Identify trigger source (webhook, schedule, manual)
- [ ] Identify data source (API, DB, file, service)
- [ ] Identify output (API, DB, notification, file)
- [ ] Identify constraints (real-time vs periodic, auth requirements)

### Phase 2: Design (Data Flow)
- [ ] Map input → process → output
- [ ] Plan error handling strategy
- [ ] Plan branching/conditional logic
- [ ] Document assumptions

### Phase 3: Implement (Build Workflow)
- [ ] Create trigger node
- [ ] Add data source nodes
- [ ] Configure authentication
- [ ] Add transformation nodes
- [ ] Add output nodes
- [ ] Configure error handling

### Phase 4: Validate (Pre-Deployment)
- [ ] Validate each node
- [ ] Validate complete workflow
- [ ] Test with sample data
- [ ] Handle edge cases

### Phase 5: Deploy (Production)
- [ ] Review settings (execution order, timeout)
- [ ] Activate workflow
- [ ] Monitor executions
- [ ] Document in KB

---

## Core Data Flow Patterns

### Pattern A: Linear Flow
```
Trigger → Transform → Action → End
```
**Use**: Simple single-path workflows

**Example**: Webhook → Respond
```
Webhook (POST) → Respond to Webhook
```

### Pattern B: Branching Flow
```
Trigger → IF (condition) → [True Path]
                        → [False Path]
```
**Use**: Different actions based on conditions

**Example**: Webhook → Validate → [Success/Error handling]
```
Webhook → IF (valid email?) → Slack (success)
                            → Error (invalid)
```

### Pattern C: Parallel Processing
```
Trigger → [Branch 1] ├→ Merge → End
       └→ [Branch 2] ┘
```
**Use**: Independent operations that run simultaneously

**Example**: Get data from multiple APIs
```
Schedule → HTTP (API 1) ┤
        → HTTP (API 2) ├→ Merge → Transform → DB
        → HTTP (API 3) ┘
```

### Pattern D: Loop/Batch
```
Trigger → Split in Batches → Process → Loop Until Complete
```
**Use**: Processing large datasets in chunks

**Example**: Process 1000 records in batches of 100
```
Schedule → HTTP (fetch 1000) → Split (100 per batch) → Foreach → Process → DB
```

### Pattern E: Error Handling
```
Main Flow → [Success] → End
         → [Error] → Error Trigger → Alert/Retry
```
**Use**: Catching and handling errors gracefully

**Example**: 
```
Webhook → HTTP Request ├→ Respond (200 OK)
                    └→ Error Trigger → Slack Alert
```

---

## Webhook Pattern (Most Common - 35%)

### Structure
```
Webhook (POST) → Validate → Transform → Respond
```

### Implementation Checklist
- [ ] Create Webhook node with `path: "your-path"`
- [ ] Set HTTP method: POST
- [ ] Create Respond node
- [ ] Map webhook payload to response
- [ ] Add validation (IF node for checks)
- [ ] Test with curl/Postman

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
  ],
  "connections": {
    "Webhook": {
      "main": [[{"node": "Respond", "type": "main", "index": 0}]]
    }
  }
}
```

### URL After Activation
```
POST http://127.0.0.1:5678/webhook/cindy-telegram
```

---

## HTTP API Pattern (45%)

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

### Configuration Example
```json
{
  "nodes": [
    {
      "name": "HTTP Request",
      "type": "n8n-nodes-base.httpRequest",
      "parameters": {
        "method": "GET",
        "url": "https://api.github.com/repos/user/repo/issues",
        "authentication": "predefinedCredentialType",
        "nodeCredentialType": "httpHeaderAuth"
      }
    },
    {
      "name": "Transform",
      "type": "n8n-nodes-base.set",
      "parameters": {
        "assignments": {
          "name": "={{$json.title}}",
          "status": "={{$json.state}}"
        }
      }
    }
  ]
}
```

---

## Database Pattern (28%)

### Structure
```
Schedule → Query → Transform → Write → Verify
```

### Implementation Checklist
- [ ] Create Schedule trigger (cron)
- [ ] Create Database node (Postgres/MySQL)
- [ ] Configure SELECT query
- [ ] Add Set node for transform
- [ ] Add INSERT/UPDATE node
- [ ] Verify with SELECT after write

### Configuration Example
```json
{
  "nodes": [
    {
      "name": "Query Source",
      "type": "n8n-nodes-base.postgres",
      "parameters": {
        "operation": "executeQuery",
        "query": "SELECT * FROM events WHERE created_at > NOW() - INTERVAL 1 HOUR"
      }
    },
    {
      "name": "Write Destination",
      "type": "n8n-nodes-base.mysql",
      "parameters": {
        "operation": "insert",
        "table": "events_copy",
        "columns": "id,text,created_at"
      }
    }
  ]
}
```

---

## Common Workflow Gotchas

### 1. Webhook Data Structure
**Problem**: `{{$json.email}}` returns undefined
**Solution**: Data is nested under body: `{{$json.body.email}}`

### 2. Multiple Items Processing
**Problem**: Node processes all items, I only want one
**Solution**: Use `{{$json[0]}}` for first item or "Execute Once" option

### 3. Authentication Failures
**Problem**: 401/403 errors on API calls
**Solution**: Use Credentials section, not parameters. Test before deployment.

### 4. Node Execution Order
**Problem**: Nodes running in unexpected order
**Solution**: Check workflow settings → Execution Order (v0 vs v1)

### 5. Expression Errors
**Problem**: `{{$json.field}}` shows as literal text
**Solution**: Ensure `{{}}` syntax and proper escaping

---

## Integration Guidance

**Use with n8n-mcp-tools-expert** to:
- Find nodes for your pattern (search_nodes operation)
- Understand node operations (get_node operation)
- Deploy templates (n8n_deploy_template operation)

**Use with n8n-node-configuration** to:
- Configure operation-specific parameters
- Understand field dependencies
- Handle conditional requirements

**Use with n8n-validation-expert** to:
- Validate workflow structure
- Fix validation errors
- Handle warnings

**Use with n8n-workflow-deployment** to:
- Deploy workflow via API
- Manage activation/deactivation
- Handle credential injection

---

## Real-World Examples

### Example 1: Form → Database → Slack
```
Webhook (form submit) 
  → IF (validate email)
    → Postgres (insert)
    → Slack (notify)
```

### Example 2: Scheduled Data Sync
```
Schedule (daily 9 AM)
  → HTTP (fetch from source API)
  → Set (transform fields)
  → MySQL (insert/update)
  → Email (send summary)
```

### Example 3: Multi-API Parallel Fetch
```
Schedule
  ├→ HTTP (API 1)
  ├→ HTTP (API 2)
  ├→ HTTP (API 3)
  → Merge
  → Set (transform combined data)
  → Postgres (store)
```

### Example 4: Error Handling with Retry
```
Webhook
  → HTTP Request (may fail)
    ├→ Success → Respond (200)
    └→ Error Trigger
      → IF (retry < 3)
        → HTTP Request (retry)
      → ELSE
        → Stop and Error
```

---

## Best Practices Summary

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

**Trigger Options**: Webhook, Schedule (Cron), Manual, Polling
**Data Sources**: HTTP, Database, Service nodes, Code
**Transformation**: Set, Code, IF, Switch, Merge
**Outputs**: HTTP, Database, Email, Slack, File
**Error Handling**: Error Trigger, IF conditions, Continue On Fail

---

**Last Updated**: March 2026 (Sprint S2)  
**Source**: Cindy-Telegram production workflow validation
**Status**: Production-ready patterns
