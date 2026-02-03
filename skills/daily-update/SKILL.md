---
name: daily-update
description: 'Generate concise daily status updates by querying Jira and GitHub activity. Use when asked to generate daily update, standup report, status summary, work summary, yesterday summary, today plan, or weekly progress. Queries actual Jira tickets and GitHub commits to create actionable updates with no emojis.'
license: Apache-2.0
metadata:
  author: yannig
  version: "1.0"
allowed-tools: mcp_atlassian_atl_searchJiraIssuesUsingJql mcp_atlassian_atl_getAccessibleAtlassianResources mcp_github_github_list_commits mcp_github_github_list_pull_requests mcp_github_github_pull_request_read mcp_github_github_get_me Read
---

# Daily Update Generator

Generates concise, stakeholder-friendly daily updates by querying actual Jira and GitHub activity. Produces actionable summaries focused on meaningful work progress.

## When to Use This Skill

- User requests: "generate my daily update for [today/yesterday/week]"
- User requests: "create standup report", "status summary", "work summary"
- User wants to document completed work and planned tasks
- User needs update with actual data from Jira and GitHub

## Configuration Loading

1. **Check for project config**: Read `.github/skills/daily-update/config.md` in current workspace
2. **Required config values**:
   - Jira Cloud ID (UUID)
   - Jira Instance URL (e.g., `netfeasa.atlassian.net`)
   - Ticket Prefix (e.g., `CTA-`)
   - GitHub Repo (format: `owner/repo`)
   - Output Path (e.g., `.copilot/daily_update.md`)
3. **If config not found**: Look for values in `.github/copilot-instructions.md` under "Project Context"
4. **If still not found**: Ask user for these values and offer to create config file

## Prerequisites

- MCP servers must be connected and authenticated
- Git repository context available
- User has Jira and GitHub activity to report

## Workflow

### Step 1: Determine Time Range

User specifies one of:
- **today**: From start of current day (00:00) to now
- **yesterday**: Full previous day (00:00 to 23:59)
- **week**: Last 7 days from now

Calculate ISO 8601 timestamps for query filters.

### Step 2: Query Jira Activity (REQUIRED)

**First, verify MCP server connection:**

1. Call `mcp_atlassian_atl_getAccessibleAtlassianResources` to test connection
2. If it fails or returns error:
   - Wait 2 seconds
   - Retry once more
   - If still fails, inform user: "Atlassian MCP server is unavailable. Please reconnect it in VS Code settings (Ctrl+Shift+P → 'MCP: Restart Server')"
   - STOP and do not proceed with stale data

**Then query Jira with JQL:**
```
(assignee = currentUser() OR reporter = currentUser() OR comment ~ currentUser()) 
AND updated >= startOfDay(-1d)
```

Adjust date filter based on time range:
- **today**: `updated >= startOfDay()`
- **yesterday**: `updated >= startOfDay(-1d) AND updated < startOfDay()`
- **week**: `updated >= startOfDay(-7d)`

Extract for each issue:
- Issue key (e.g., CTA-350)
- Summary
- Status
- Type
- Links to issue

### Step 3: Query GitHub Activity (REQUIRED)

**Get current user first**:
```
mcp_github_github_get_me
```

**Query commits**:
```
mcp_github_github_list_commits(owner, repo, author: username, since: timestamp)
```
- Use timestamp from Step 1 for `since` parameter
- Retrieve at least 30 commits to ensure coverage
- Extract: commit SHA (first 8 chars), message (first line), Jira ticket from message

**Query pull requests**:
```
mcp_github_github_list_pull_requests(owner, repo, state: "all", sort: "updated", direction: "desc")
```
- Filter PRs updated in time range
- For each relevant PR, get reviews: `mcp_github_github_pull_request_read(method: "get_reviews")`
- Identify PRs where user submitted review (approved, commented, requested changes)
- Extract: PR number, title, Jira ticket, review action

### Step 4: Categorize Activity

**Yesterday section** (what was completed):
- PRs reviewed and approved/commented
- Jira tickets completed (status: Done, Closed, Resolved)
- Major commits with meaningful progress (group by Jira ticket)
- New bugs/issues created

**Today section** (what's planned):
- Jira tickets in progress (status: In Progress, In Review, Need Review)
- Planned meetings or syncs mentioned
- Next tickets to work on

**Blockers section**:
- Active blockers from Jira or user's context
- Default to "None" if no blockers

**Notes section**:
- Time-sensitive items
- Context about work in progress
- Any important discoveries (bugs, architectural decisions)

### Step 5: Generate Output

Write to output path from config using this exact format:

```markdown
## Daily Update — {{Day}}, {{Month}} {{Date}}, {{Year}}

**Yesterday:**  
- [PR #XXX] - Brief description (Jira ticket)
- [Jira ticket] - Brief description and status
- Key commits grouped by ticket
- Bugs/issues identified

**Today:** 
- Planned PRs or reviews
- Jira tickets to work on with brief descriptions
- Planned meetings or syncs

**Blockers:**  
- Active blocker description or "None"

**Notes:**  
- Time-sensitive context
- Important discoveries or decisions
```

### Step 6: Validate Output (REQUIRED)

Run validation script:
```bash
~/.copilot/skills/daily-update/scripts/validate-format.sh <output-path>
```

**Validation must pass before considering task complete.**

If validation fails:
1. Show errors to user
2. Fix issues
3. Re-validate
4. Do not proceed until validation passes

## Stop Rules (CRITICAL)

1. **MCP Server Connection Issues**: 
   - **First**: Always call `mcp_atlassian_atl_getAccessibleAtlassianResources` to verify connection
   - **If fails**: Wait 2 seconds, retry once
   - **If still fails**: Tell user "Atlassian MCP server is unavailable. Please reconnect it in VS Code (Ctrl+Shift+P → 'MCP: Restart Server')" and STOP
   - **For GitHub MCP**: If `mcp_github_github_get_me` fails, inform user similarly
   - Do NOT proceed with stale data, cached data, or assumptions

2. **Config Missing**: If cannot load Jira Cloud ID or GitHub repo:
   - STOP and ask user for required values
   - Offer to create `.github/skills/daily-update/config.md` with provided values

3. **Validation Fails**: If output does not pass validation:
   - STOP and show validation errors
   - Fix errors based on validator output
   - Re-run validation
   - Do not mark task complete until validation passes

## General Rules (Your Work Style)

- **Use actual data only**: Query Jira and GitHub, never hallucinate or guess
- **Keep it concise**: Focus on meaningful work progress, skip implementation details
- **Action-oriented**: Bullet points with links to tickets/PRs
- **No emojis**: Never use emojis in output
- **Skip minutiae**: Don't include typo fixes, review comments, minor refactoring details
- **Real work only**: Only document what was actually completed, not planned or hypothetical

## Output Schema

See [template.md](references/template.md) for detailed schema and examples.

## Troubleshooting

| Issue | Solution |
|-------|----------|
| MCP returns 401/403 | User must reconnect MCP server in VS Code settings |
| No commits found | Check time range, verify user has commits in that period |
| No Jira issues found | Check JQL syntax, verify user has activity in Jira |
| Validation fails | Read error output, fix specific heading/format issues |
| Config not found | Create `.github/skills/daily-update/config.md` in workspace |

## References

- [Output Template](references/template.md) - Required format and examples
- [JQL Patterns](references/jql-patterns.md) - Jira query examples
