# JQL Query Patterns

## Common Patterns for Daily Updates

### User Activity (Today)
```jql
(assignee = currentUser() OR reporter = currentUser() OR comment ~ currentUser()) 
AND updated >= startOfDay()
```

### User Activity (Yesterday)
```jql
(assignee = currentUser() OR reporter = currentUser() OR comment ~ currentUser()) 
AND updated >= startOfDay(-1d) 
AND updated < startOfDay()
```

### User Activity (Last 7 Days)
```jql
(assignee = currentUser() OR reporter = currentUser() OR comment ~ currentUser()) 
AND updated >= startOfDay(-7d)
```

### Completed Work (Yesterday)
```jql
(assignee = currentUser() OR reporter = currentUser()) 
AND status IN (Done, Closed, Resolved)
AND updated >= startOfDay(-1d) 
AND updated < startOfDay()
```

### In Progress Work
```jql
assignee = currentUser() 
AND status IN ("In Progress", "In Review", "Need Review")
ORDER BY updated DESC
```

### Recently Created Issues
```jql
reporter = currentUser() 
AND created >= startOfDay(-1d)
ORDER BY created DESC
```

## Field Extraction

From each Jira issue, extract:
- **key**: Ticket ID (e.g., "CTA-350")
- **summary**: Issue title
- **status.name**: Current status
- **issuetype.name**: Type (Story, Bug, Task, Subtask)
- **created**: Creation timestamp
- **updated**: Last update timestamp

## Date Functions

| Function | Description |
|----------|-------------|
| `startOfDay()` | Today at 00:00 |
| `startOfDay(-1d)` | Yesterday at 00:00 |
| `startOfDay(-7d)` | 7 days ago at 00:00 |
| `endOfDay()` | Today at 23:59 |
| `endOfDay(-1d)` | Yesterday at 23:59 |

## Example MCP Call

```javascript
mcp_atlassian_atl_searchJiraIssuesUsingJql({
  cloudId: "788c6eac-d63e-46de-a415-df345e814eaa",
  jql: "(assignee = currentUser() OR reporter = currentUser()) AND updated >= startOfDay(-1d)",
  fields: ["key", "summary", "status", "issuetype", "created", "updated"],
  maxResults: 50,
  startAt: 0
})
```

## Filtering Results

After querying, filter results by:
1. **Status changes**: Issues that moved to Done/Closed
2. **User activity**: Issues where user commented or made changes
3. **Relevance**: Issues actively worked on vs passively watched
4. **Time**: Verify update timestamp falls in target range

## Common Issues

| Problem | Solution |
|---------|----------|
| Too many results | Add status or date constraints |
| No results found | Check date range, verify user has activity |
| Permission errors | Verify cloudId is correct, MCP authenticated |
| Query timeout | Reduce maxResults, narrow date range |
