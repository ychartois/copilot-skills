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

1. **Check for project config**: Try to read `.github/skills/daily-update/config.md` in current workspace
2. **Fallback to user config**: If not found, try `~/.copilot/skills/daily-update/config.md`
3. **Required config values**:
   - Jira Cloud ID (UUID)
   - Jira Instance URL (e.g., `netfeasa.atlassian.net`)
   - Ticket Prefix (e.g., `CTA-`)
   - GitHub Repo (format: `owner/repo`)
   - Output Path (e.g., `.copilot/daily_update.md`)
4. **If config not found**: Look for values in `.github/copilot-instructions.md` under "Project Context"
5. **If still not found**: Ask user for these values and offer to create config file

## Prerequisites

- MCP servers must be connected and authenticated
- MCP atlassian `searchJiraIssuesUsingJql` must be enabled
- Git repository context available
- User has Jira and GitHub activity to report

## Workflow Checklist

**MANDATORY: Execute ALL steps in order. Do NOT skip any step.**

- [ ] Step 1: Load configuration
- [ ] Step 2: Verify MCP connections (Jira + GitHub)
- [ ] Step 3: Query Jira for YESTERDAY (startOfDay(-1d) to startOfDay())
- [ ] Step 4: Query Jira for TODAY (startOfDay() onwards)
- [ ] Step 5: Query GitHub commits (yesterday's date range)
- [ ] Step 6: Query GitHub pull requests (updated in last 7 days)
- [ ] Step 7: Categorize activity into Yesterday/Today/Blockers/Notes
- [ ] Step 8: Generate output using exact template format
- [ ] Step 9: Run validation script
- [ ] Step 10: Confirm validation passed

## Required Queries Reference

When user requests a daily update, you MUST execute these exact queries:

### Jira Queries (BOTH required)
```jql
# Query 1: Yesterday's activity
assignee = currentUser() 
AND updated >= startOfDay(-1d) AND updated < startOfDay()
ORDER BY updated DESC

# Query 2: Today's activity  
assignee = currentUser()
AND updated >= startOfDay()
ORDER BY updated DESC
```

### GitHub Queries (ALL required)
```
# Query 1: Get current user
mcp_github_github_get_me

# Query 2: Search for commits across entire organization (yesterday onwards)
mcp_io_github_git_search_code(
  query: "org:Net-Feasa-Limited author:ychartois committer-date:>=YYYY-MM-DD",
  perPage: 100
)
Note: Use yesterday's date in YYYY-MM-DD format for committer-date filter

# Query 3: Search pull requests across entire organization (last 7 days)
mcp_io_github_git_search_pull_requests(
  query: "org:Net-Feasa-Limited author:ychartois updated:>=YYYY-MM-DD",
  sort: "updated",
  order: "desc",
  perPage: 50
)
Note: Use 7 days ago date in YYYY-MM-DD format
```

## Workflow

### Step 1: Determine Time Range

User specifies one of:
- **today**: From start of current day (00:00) to now
- **yesterday**: Full previous day (00:00 to 23:59), If previous is a Satruday or Sunday, Yesterday is the Friday
- **week**: Last 7 days from now

Calculate ISO 8601 timestamps for query filters.

### Step 2: Verify MCP Server Connections (REQUIRED - DO NOT SKIP)

**Jira MCP verification:**

1. Call `mcp_atlassian_atl_getAccessibleAtlassianResources` to test connection
2. If it fails or returns error:
   - Wait 2 seconds
   - Retry once more
   - If still fails, inform user: "Atlassian MCP server is unavailable. Please reconnect MCP Servers"
   - **STOP - Do not proceed with stale data**

**GitHub MCP verification:**

1. Call `mcp_github_github_get_me`
2. If it fails, inform user: "GitHub MCP server is unavailable"
   - **STOP - Do not proceed**

### Step 3: Query Jira for YESTERDAY (REQUIRED - DO NOT SKIP)

Query Jira with JQL for yesterday's activity:
```
(assignee = currentUser() OR reporter = currentUser() OR comment ~ currentUser()) 
AND updated >= startOfDay(-1d) AND updated < startOfDay()
ORDER BY updated DESC
```

Extract for each issue:
- Issue key (e.g., CTA-350)
- Summary
- Status
- Type
- Links to issue

### Step 4: Query Jira for TODAY (REQUIRED - DO NOT SKIP)

Query Jira with JQL for today's activity:
```
(assignee = currentUser() OR reporter = currentUser() OR comment ~ currentUser())
AND updated >= startOfDay()
ORDER BY updated DESC
```

Extract same fields as Step 3.

### Step 5: Query GitHub Activity Across Organization (REQUIRED - DO NOT SKIP)

**Get current user first**:
```
mcp_github_github_get_me
```

**Search commits across Net-Feasa-Limited organization (YESTERDAY's date range)**:
```
mcp_io_github_git_search_code(
  query: "org:Net-Feasa-Limited author:ychartois committer-date:>=YYYY-MM-DD",
  perPage: 100
)
```
- Use yesterday's date in YYYY-MM-DD format (e.g., 2026-02-05)
- Retrieve up to 100 results to ensure full coverage across all repos
- Extract: repository name, commit SHA (first 8 chars), message (first line), Jira ticket from message
- Group commits by Jira ticket reference and repository
- Note: GitHub code search finds commits across entire organization

**Search pull requests across organization (last 7 days for context)**:
```
mcp_io_github_git_search_pull_requests(
  query: "org:Net-Feasa-Limited author:ychartois updated:>=YYYY-MM-DD",
  sort: "updated",
  order: "desc",
  perPage: 50
)
```
- Use date from 7 days ago in YYYY-MM-DD format
- Search across all Net-Feasa-Limited repositories
- For each relevant PR, check if merged yesterday
- Extract: repository name, PR number, title, Jira ticket, merged_at timestamp, state

### Step 6: Categorize Activity

**Yesterday section** (what was completed):
- Jira tickets updated YESTERDAY (from Step 3 query)
- Commits from yesterday (grouped by Jira ticket)
- PRs merged yesterday
- New bugs/issues created

**Today section** (what's planned):
- User's explicit focus from input (MOST IMPORTANT - use verbatim)
- Jira tickets updated TODAY (from Step 4 query)
- Scheduled meetings/events mentioned by user
- Planned next steps

**Blockers section**:
- Extract from user input (e.g., "Android localStorage issues")
- Jira tickets marked as blocked
- Default to "None" if no blockers mentioned

**Notes section**:
- Additional context from user input
- Time-sensitive items
- Important discoveries or architectural decisions

### Step 7: Generate Output

Write to output path from config using this exact format:

```markdown
## Daily Update — {{Day}}, {{Month}} {{Date}}, {{Year}}

**Yesterday:**  
- [CTA-XXX](https://netfeasa.atlassian.net/browse/CTA-XXX) - Brief description (Status: XXX)
- Commits: X commits on [brief description] (CTA-XXX)
- [PR #XXX](https://github.com/owner/repo/pull/XXX) - Brief description (CTA-XXX) [merged]

**Today:** 
- [User's explicit focus - use their exact words]
- [CTA-XXX](https://netfeasa.atlassian.net/browse/CTA-XXX) - Planned work
- Scheduled events: [meetings from user input]

**Blockers:**  
- Active blocker description (extracted from user input) or "None"

**Notes:**  
- Time-sensitive context
- Important discoveries or decisions
```

**Linking Format:**
- GitHub PRs: `[PR #123](https://github.com/owner/repo/pull/123)`
- Jira tickets: `[CTA-123](https://netfeasa.atlassian.net/browse/CTA-123)`

### Step 8: Validate Output (REQUIRED - DO NOT SKIP)

Run validation script:
```bash
~/.copilot/skills/daily-update/scripts/validate-format.sh ~/.copilot/daily_update.md
```

**If validation fails:**
- Review errors from script output
- Fix format issues in generated content
- Re-run validation
- **Do not deliver output until validation passes**

### Step 9: Confirm to User

After successful validation, report:
```
✅ Generated daily update for [date]
✅ Jira: X tickets from yesterday, Y tickets for today
✅ GitHub: N commits from yesterday, M pull requests
✅ Validation passed
```

## Stop Rules

**HALT immediately and inform user if:**

1. ❌ **Jira MCP unavailable** → "Atlassian MCP server unavailable. Please reconnect MCP servers." (Do NOT use stale data)
2. ❌ **GitHub MCP unavailable** → "GitHub MCP server unavailable." (Do NOT proceed)
3. ❌ **Both Jira queries return 0 results** → Ask: "No Jira activity found for yesterday or today. Is this expected (weekend/vacation)?"
4. ❌ **Validation fails** → Fix format issues before delivering
5. ❌ **User input unclear** → Ask: "What are you working on today?"

**Never:**
- Skip MCP verification (Steps 2, 3, 4, 5)
- Skip validation (Step 8)
- Proceed without querying BOTH Jira queries (yesterday AND today)
- Proceed without querying GitHub (commits AND pull requests)
- Deliver unvalidated output
- Guess at missing data - always query actual sources
- Use today's Jira data for yesterday's section (most common error)

## Error Recovery

If a query fails:
1. Log the error message clearly
2. Wait 2 seconds
3. Retry once
4. If still failing:
   - Inform user with specific error: "Failed to query [source]: [error message]"
   - Ask: "Proceed with partial data? (Missing: [source])"
5. If user approves partial data:
   - Add note to output: "⚠️ Note: [Source] data unavailable - [reason]"
   - Mark affected sections clearly

## Examples
- Use actual URLs from config (GitHub repo, Jira instance)

**Section Guidelines:**
- **Yesterday**: What was actually completed (merged PRs, closed tickets, major work, bugs found)
- **Today**: What's planned next (active tickets, planned PRs, scheduled meetings) - keep to 3-5 items
- **Blockers**: Active impediments or "None"
- **Notes**: Context that doesn't fit elsewhere (optional, can be brief or omitted)

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
