---
name: n8n-node-configuration
description: Operation-aware node configuration guidance. Use when configuring nodes, understanding property dependencies, determining required fields, choosing between get_node detail levels, or learning common configuration patterns by node type.
---

# n8n Node Configuration

Expert guidance for configuring n8n nodes with operation-aware parameter discovery.

**Ported from**: `.cline/skills/n8n-node-configuration` (March 2026)
**Focus**: Progressive disclosure pattern - start minimal, add as needed

---

## Configuration Philosophy

**Key principle**: Not all fields are always required - it depends on operation!

```
Resource Selection → Operation Selection → Field Dependencies
                                              ↓
                                        Required Fields
                                              ↓
                                        Optional Fields
```

---

## Core Concepts

### 1. Operation-Aware Configuration

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
  // channel NOT required here
}
```

**Key**: Resource + operation determine required fields!

### 2. Property Dependencies

Fields appear/disappear based on other field values:

```javascript
// HTTP Request: GET method
{
  "method": "GET",
  "url": "https://api.example.com"
  // sendBody not visible (GET has no body)
}

// HTTP Request: POST method
{
  "method": "POST",
  "url": "https://api.example.com",
  "sendBody": true,           // Now visible!
  "body": {                   // Required when sendBody=true
    "contentType": "json",
    "content": {...}
  }
}
```

**Mechanism**: `displayOptions` control field visibility

### 3. Progressive Discovery

**Use the right detail level**:

1. **Standard** (DEFAULT) - ~1-2K tokens
   - Required fields + common options
   - Covers 95% of needs

2. **Full** - ~3-8K tokens
   - Complete schema with all properties
   - Use only when standard insufficient

3. **Search Mode** - Find specific fields
   - For locating properties by name

---

## Configuration Workflow

### Standard Process

```
1. Identify node type and operation
   ↓
2. Get node info (standard detail)
   ↓
3. Configure required fields
   ↓
4. Validate configuration
   ↓
5. If field unclear → search properties
   ↓
6. Add optional fields as needed
   ↓
7. Validate again
   ↓
8. Deploy
```

### Example: HTTP Request Node

**Goal**: POST JSON to API

**Step 1**: Identify
```
Node: HTTP Request
Method: POST
Auth: None
```

**Step 2**: Get Info
```javascript
// Returns: method, url, sendBody, body, authentication
```

**Step 3**: Minimal Config
```javascript
{
  "method": "POST",
  "url": "https://api.example.com/create",
  "authentication": "none"
}
```

**Step 4**: Validate
```
Error: "sendBody required for POST"
```

**Step 5**: Add sendBody
```javascript
{
  "method": "POST",
  "url": "https://api.example.com/create",
  "authentication": "none",
  "sendBody": true
}
```

**Step 6**: Validate Again
```
Error: "body required when sendBody=true"
```

**Step 7**: Complete Config
```javascript
{
  "method": "POST",
  "url": "https://api.example.com/create",
  "authentication": "none",
  "sendBody": true,
  "body": {
    "contentType": "json",
    "content": {
      "name": "={{$json.name}}",
      "email": "={{$json.email}}"
    }
  }
}
```

**Step 8**: Final Validation
```
✓ Valid!
```

---

## Common Node Patterns

### Pattern 1: Resource/Operation Nodes

**Examples**: Slack, Google Sheets, Airtable

```javascript
{
  "resource": "<entity>",      // What type of thing
  "operation": "<action>",     // What to do with it
  // ... operation-specific fields
}
```

**How to configure**:
1. Choose resource
2. Choose operation  
3. See operation-specific requirements
4. Configure required fields

### Pattern 2: HTTP-Based Nodes

**Examples**: HTTP Request, Webhook

```javascript
{
  "method": "<HTTP_METHOD>",
  "url": "<endpoint>",
  "authentication": "<type>",
  // ... method-specific fields
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
  // ... operation-specific fields
}
```

**Dependencies**:
- operation="executeQuery" → query required
- operation="insert" → table + values required
- operation="update" → table + values + where required

### Pattern 4: Conditional Logic Nodes

**Examples**: IF, Switch, Merge

```javascript
{
  "conditions": {
    "<type>": [
      {
        "operation": "<operator>",
        "value1": "...",
        "value2": "..."  // Only for binary operators
      }
    ]
  }
}
```

**Dependencies**:
- Binary operators (equals, contains) → value1 + value2
- Unary operators (isEmpty) → value1 only

---

## Operation-Specific Examples

### Slack Node

**Post Message**:
```javascript
{
  "resource": "message",
  "operation": "post",
  "channel": "#general",
  "text": "Hello!"
}
```

**Update Message**:
```javascript
{
  "resource": "message",
  "operation": "update",
  "messageId": "1234567890",
  "text": "Updated!"
}
```

**Create Channel**:
```javascript
{
  "resource": "channel",
  "operation": "create",
  "name": "new-channel",
  "isPrivate": false
}
```

### HTTP Request Node

**GET Request**:
```javascript
{
  "method": "GET",
  "url": "https://api.example.com/users",
  "authentication": "predefinedCredentialType",
  "nodeCredentialType": "httpHeaderAuth"
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
        "value2": "active"  // Binary: needs value2
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
        // No value2 - unary operator
      }
    ]
  }
}
```

---

## Handling Conditional Requirements

### Example: HTTP Request Body

**Rule**: body required when:
- sendBody = true AND
- method IN (POST, PUT, PATCH, DELETE)

**Discovery options**:

1. **Read validation error**:
   ```
   Error: "body required when sendBody=true"
   ```

2. **Search for property**:
   ```
   get_node({mode: "search_properties", propertyQuery: "body"})
   // Shows: displayOptions rules
   ```

3. **Iterate and validate**:
   - Start minimal
   - Validation tells you what's missing
   - Add fields iteratively

---

## Configuration Anti-Patterns

### ❌ Over-configure Upfront

**Bad**:
```javascript
// Adding every possible field
{
  "method": "GET",
  "url": "...",
  "sendQuery": false,
  "sendHeaders": false,
  "sendBody": false,
  "timeout": 10000,
  // ... 20 more fields
}
```

**Good**:
```javascript
// Start minimal
{
  "method": "GET",
  "url": "...",
  "authentication": "none"
}
// Add fields only when needed
```

### ❌ Skip Validation

**Bad**:
```javascript
const config = {...};
n8n_update_partial_workflow({...});  // YOLO
```

**Good**:
```javascript
const config = {...};
const result = validate_node({...});
if (result.valid) {
  n8n_update_partial_workflow({...});
}
```

### ❌ Ignore Operation Context

**Bad**:
```javascript
// Same config for all Slack operations
{
  "resource": "message",
  "operation": "post",
  "channel": "#general"
}

// Then switching operation without updating
{
  "resource": "message",
  "operation": "update",
  "channel": "#general"  // Wrong field for update!
}
```

**Good**:
```javascript
// Check requirements when changing operation
get_node({nodeType: "nodes-base.slack"});
// See what update operation needs (messageId, not channel)
```

---

## Best Practices

### ✅ Do

1. **Start with standard detail**
   - ~1-2K tokens response
   - Covers 95% of needs
   - Default level

2. **Validate iteratively**
   - Configure → Validate → Fix → Repeat
   - 2-3 iterations is normal
   - Read errors carefully

3. **Use search mode when stuck**
   - If field seems missing, search for it
   - Understand visibility rules
   - `get_node({mode: "search_properties"})`

4. **Respect operation context**
   - Different operations = different requirements
   - Always check when changing operation
   - Don't assume configs are transferable

5. **Trust auto-sanitization**
   - Operator structure fixed automatically
   - Don't manually add/remove singleValue
   - Focus on business logic

### ❌ Don't

1. **Jump to detail="full" immediately**
   - Try standard first
   - Only escalate if needed
   - Full is 3-8K tokens

2. **Configure blindly**
   - Always validate before deploying
   - Understand why fields are required
   - Use search for conditional fields

3. **Copy configs without understanding**
   - Different operations need different fields
   - Validate after copying
   - Adjust for new context

4. **Manually fix auto-sanitization**
   - Let system handle operator structure
   - Focus on business logic
   - Save and let system fix

---

## Summary

**Configuration Strategy**:
1. Start with `get_node` (standard detail)
2. Configure required fields for operation
3. Validate configuration
4. Search properties if stuck
5. Iterate until valid (avg 2-3 cycles)
6. Deploy with confidence

**Key Principles**:
- **Operation-aware**: Different operations = different requirements
- **Progressive disclosure**: Start minimal, add as needed
- **Dependency-aware**: Understand field visibility rules
- **Validation-driven**: Let validation guide configuration

**Related Skills**:
- **n8n-mcp-tools-expert** - Discovery tools
- **n8n-validation-expert** - Error handling
- **n8n-expression-syntax** - Expression fields
- **n8n-workflow-patterns** - Apply patterns

---

**Last Updated**: March 2026 (Sprint S2)  
**Status**: Production-tested patterns
