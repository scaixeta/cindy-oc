---
name: n8n-node-configuration
description: Operation-aware node configuration guidance. Use when configuring nodes, understanding property dependencies, determining required fields, choosing between get_node detail levels, or learning common configuration patterns by node type.
---

# n8n Node Configuration

Expert guidance for configuring n8n nodes with operation-aware parameters.

**Ported to**: `.codex/skills/n8n-node-configuration` (March 2026)
**Pattern**: Progressive disclosure - start minimal, add as needed
**Status**: Production-tested

---

## Key Principle

**Not all fields are always required - it depends on operation!**

```
Resource → Operation → Field Dependencies → Required Fields → Optional Fields
```

---

## Operation-Aware Configuration

Different operations require different fields:

```javascript
// Slack: post operation
{
  "resource": "message",
  "operation": "post",
  "channel": "#general",      // Required for post
  "text": "Hello!"            // Required for post
}

// Slack: update operation
{
  "resource": "message",
  "operation": "update",
  "messageId": "1234567890",  // Required for update (different!)
  "text": "Updated!"          // Required for update
}
```

**Key**: Resource + operation determine required fields!

---

## Property Dependencies

Fields appear/disappear based on other field values:

```javascript
// HTTP Request: GET
{
  "method": "GET",
  "url": "https://api.example.com"
  // sendBody not visible
}

// HTTP Request: POST
{
  "method": "POST",
  "url": "https://api.example.com",
  "sendBody": true,           // Now visible!
  "body": {...}               // Required when sendBody=true
}
```

---

## Configuration Workflow

```
1. Identify node type + operation
   ↓
2. Get node info (standard detail)
   ↓
3. Configure required fields
   ↓
4. Validate configuration
   ↓
5. If unclear → search properties
   ↓
6. Add optional fields
   ↓
7. Validate again
   ↓
8. Deploy
```

---

## Common Node Patterns

### Pattern 1: Resource/Operation Nodes
**Examples**: Slack, Google Sheets, Airtable

```javascript
{
  "resource": "<entity>",
  "operation": "<action>",
  // operation-specific fields
}
```

### Pattern 2: HTTP-Based Nodes
**Examples**: HTTP Request, Webhook

```javascript
{
  "method": "<GET|POST|PUT|PATCH|DELETE>",
  "url": "<endpoint>",
  "authentication": "<type>"
  // method-specific fields
}
```

**Dependencies**:
- POST/PUT/PATCH → sendBody available
- sendBody=true → body required
- authentication != "none" → credentials required

### Pattern 3: Database Nodes
**Examples**: Postgres, MySQL, MongoDB

```javascript
{
  "operation": "<query|insert|update|delete>",
  // operation-specific fields
}
```

**Dependencies**:
- executeQuery → query required
- insert → table + values required
- update → table + values + where required

### Pattern 4: Conditional Nodes
**Examples**: IF, Switch

```javascript
{
  "conditions": {
    "<type>": [
      {
        "operation": "<operator>",
        "value1": "...",
        "value2": "..."  // Binary operators only
      }
    ]
  }
}
```

---

## Operation-Specific Examples

### Slack Node

**Post**:
```javascript
{
  "resource": "message",
  "operation": "post",
  "channel": "#general",
  "text": "Hello!"
}
```

**Update**:
```javascript
{
  "resource": "message",
  "operation": "update",
  "messageId": "1234567890",
  "text": "Updated!"
}
```

### HTTP Request

**GET**:
```javascript
{
  "method": "GET",
  "url": "https://api.example.com/users",
  "authentication": "predefinedCredentialType"
}
```

**POST with JSON**:
```javascript
{
  "method": "POST",
  "url": "https://api.example.com/users",
  "authentication": "none",
  "sendBody": true,
  "body": {
    "contentType": "json",
    "content": {
      "name": "John Doe",
      "email": "john@example.com"
    }
  }
}
```

### IF Node

**String Comparison** (Binary):
```javascript
{
  "conditions": {
    "string": [
      {
        "value1": "={{$json.status}}",
        "operation": "equals",
        "value2": "active"
      }
    ]
  }
}
```

**Empty Check** (Unary):
```javascript
{
  "conditions": {
    "string": [
      {
        "value1": "={{$json.email}}",
        "operation": "isEmpty"
      }
    ]
  }
}
```

---

## Detail Levels

### Standard (DEFAULT)
- ~1-2K tokens
- Required fields + common options
- **Use first**: covers 95% of needs

### Full
- ~3-8K tokens
- Complete schema
- Use only when standard insufficient

### Search Mode
- Find specific properties
- Use when field seems missing

---

## Best Practices

### ✅ Do
1. Start with standard detail
2. Validate iteratively (avg 2-3 cycles)
3. Use search when stuck
4. Respect operation context
5. Trust auto-sanitization

### ❌ Don't
1. Jump to full detail immediately
2. Configure blindly (always validate)
3. Copy configs without understanding
4. Manually fix auto-sanitization
5. Mix operations without checking

---

## Common Anti-Patterns

### Over-configure Upfront
**Bad**:
```javascript
{
  "method": "GET",
  "sendQuery": false,
  "sendHeaders": false,
  "sendBody": false,
  // 20 more fields...
}
```

**Good**:
```javascript
{
  "method": "GET",
  "url": "...",
  "authentication": "none"
}
```

### Skip Validation
**Bad**: Configure and deploy without validating

**Good**: Validate → Deploy

### Ignore Operation Context
**Bad**: Use same config for all operations

**Good**: Check requirements when changing operation

---

## Summary

**Strategy**:
1. Identify node type + operation
2. Get node info (standard)
3. Configure required fields
4. Validate
5. Search if stuck
6. Iterate until valid
7. Deploy

**Principles**:
- Operation-aware
- Progressive disclosure
- Dependency-aware
- Validation-driven

---

**Last Updated**: March 2026 (Sprint S2)  
**Status**: Production-tested
