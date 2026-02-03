---
name: sprint-retro
description: 'Generate and update sprint retrospective documents by querying Jira and GitHub activity. Use when asked to create sprint retro, retrospective document, sprint review, update retro with planning notes, or document sprint outcomes. Combines retrospective generation with planning preview for next sprint.'
license: Apache-2.0
metadata:
  author: yannig
  version: "1.0"
allowed-tools: mcp_atlassian_atl_searchJiraIssuesUsingJql mcp_github_github_list_pull_requests mcp_github_github_search_issues Read
---

# Sprint Retrospective Generator

Generates sprint retrospective documents by querying actual Jira and GitHub activity, then updates with next sprint planning details after retrospective meeting.

## When to Use This Skill

- User requests: "generate sprint retro for sprint X"
- User requests: "create retrospective document"
- User requests: "update retro with planning notes"
- User wants to document sprint outcomes and next sprint preview
- After retrospective meeting, to add planning details

## Configuration Loading

1. **Check for project config**: Read `.github/skills/sprint-retro/config.md` in current workspace
2. **Required config values**:
   - Sprint Cadence (e.g., "1 week", "2 weeks")
   - Retro Template Path (e.g., `docs/meetings/retro-template.md`)
   - Retro Output Directory (e.g., `docs/meetings/`)
   - Jira Cloud ID (for queries)
   - Ticket Prefix (e.g., `CTA-`)
   - GitHub Repo
3. **If config not found**: Look in `.github/copilot-instructions.md` or ask user

## Prerequisites

- MCP servers must be connected and authenticated
- Sprint has date range (start and end dates)
- Jira and GitHub activity exists for sprint period

## Workflow: Generate Retrospective

### Step 1: Ask Questions First (CRITICAL)

**Never assume context. Always ask:**
- Which sprint number is this? (e.g., Sprint 12)
- What are the sprint dates? (start and end dates)
- Where should I save the retro document? (default to config path)
- Any special topics to include in the retro?

**Wait for user's answers before proceeding.**

### Step 2: Query Jira for Sprint Activity

Use `mcp_atlassian_atl_searchJiraIssuesUsingJql` with date-filtered JQL:

```jql
project = {PROJECT_KEY}
AND updated >= "{sprint_start_date}"
AND updated <= "{sprint_end_date}"
ORDER BY status DESC, updated DESC
```

Extract for each issue:
- Issue key (e.g., CTA-350)
- Summary
- Status (Done, In Progress, To Do, etc.)
- Type (Story, Bug, Task, Subtask)
- Assignee
- Created date
- Updated date

**Categorize issues**:
- **Completed**: Status = Done, Closed, Resolved
- **In Progress**: Status = In Progress, In Review, Need Review
- **Not Started**: Status = To Do, Backlog

### Step 3: Query GitHub for Sprint PRs

Use `mcp_github_github_list_pull_requests` or `mcp_github_github_search_pull_requests`:

```
repo:owner/repo is:pr merged:{sprint_start_date}..{sprint_end_date}
```

Extract:
- PR number
- Title
- Merged date
- Author
- Jira ticket from title/body

### Step 4: Generate Retrospective Document

Use this structure (can be customized via template in config):

```markdown
# Sprint {X} Retrospective — {Sprint Dates}

**Date**: {Retro Meeting Date}
**Attendees**: {Team Members}

---

## Sprint {X} Review

### Sprint Goal
{Brief statement of what sprint aimed to achieve}

### Completed Work

#### Stories & Features
{List of completed Jira stories/features with key outcomes}

- [CTA-XXX] Story title — Brief outcome
- [CTA-XXX] Story title — Brief outcome

#### Bugs Fixed
{List of bugs resolved during sprint}

- [CTA-XXX] Bug description — Resolution
- [CTA-XXX] Bug description — Resolution

#### Pull Requests Merged
{List of merged PRs with ticket references}

- [PR #XXX] PR title (CTA-XXX)
- [PR #XXX] PR title (CTA-XXX)

### In Progress (Carried Over)
{Work started but not completed}

- [CTA-XXX] Description — Status and blocker if any

### Not Started (Moved to Next Sprint)
{Planned work that didn't get started}

- [CTA-XXX] Description — Reason not started

---

## Retrospective Discussion

### What Went Well ✅
{Successes, wins, positive outcomes}

-

### What Could Be Improved 🔄
{Challenges, inefficiencies, pain points}

-

### Action Items 📋
{Concrete steps to improve next sprint}

- [ ] Action item 1
- [ ] Action item 2

### Blockers & Risks ⚠️
{Active impediments or upcoming risks}

-

---

## Sprint {X+1} Preview

### Sprint Goal
{To be filled after planning}

### Planned Work
{To be filled after planning}

- [CTA-XXX] Description
- [CTA-XXX] Description

### Key Decisions
{Important decisions made during planning}

-

---

**Next Retrospective**: {Date}
```

### Step 5: Save Document

Save to path from config (e.g., `docs/meetings/sprint-{X}-retro.md`)

Confirm with user:
- "Saved retrospective to {path}"
- "Review the document and fill in discussion sections during your retro meeting"

## Workflow: Update After Meeting

Use when user says "update retro with planning notes" or "add sprint planning details"

### Step 1: Ask Questions

- Which sprint retro file to update?
- What's the next sprint number?
- Any specific notes to add from the meeting?
- Should I query Jira for newly created tickets?

### Step 2: Read Existing Retro Document

Load the file specified by user or latest retro in directory.

### Step 3: Fill Discussion Sections

If user provides notes from meeting:
- Add to "What Went Well" section
- Add to "What Could Be Improved" section
- Add action items to "Action Items"
- Add blockers to "Blockers & Risks"

**Keep user's input verbatim** - don't rewrite or summarize.

### Step 4: Query Next Sprint Planned Work

If updating Sprint X+1 Preview section:

```jql
project = {PROJECT_KEY}
AND created >= "{retro_date}"
AND created <= "{now}"
AND (status = "To Do" OR status = "In Progress")
ORDER BY created ASC
```

Extract newly created tickets for next sprint.

### Step 5: Update Sprint X+1 Preview

Fill in:
- Sprint goal (from user or ticket summaries)
- Planned work list with ticket references
- Key decisions from planning discussion

### Step 6: Clean Up Document

- Remove any Copilot instruction comments (<!-- ... -->)
- Preserve all user-added content from meeting
- Format lists and headings consistently

### Step 7: Save Updated Document

Overwrite original file with updates.

Confirm with user:
- "Updated retrospective with planning details"
- "Sprint {X+1} preview section populated with {N} planned items"

## Stop Rules (CRITICAL)

1. **MCP Server Unavailable**: If Jira or GitHub queries fail:
   - STOP immediately
   - Tell user to reconnect MCP servers
   - Do NOT proceed with stale data

2. **Missing Sprint Dates**: If user doesn't provide start/end dates:
   - STOP and ask for specific dates
   - Don't assume or calculate dates

3. **File Already Exists**: When generating new retro:
   - WARN user if file exists
   - Ask: "File exists. Overwrite or create new version?"
   - Wait for confirmation

4. **User Hasn't Confirmed**: When updating after meeting:
   - STOP and ask which file to update
   - Don't assume latest file or auto-select

## General Rules (Your Work Style)

- **Ask questions first**: Never assume sprint dates, file paths, or meeting notes
- **Use actual data**: Query Jira and GitHub, don't hallucinate issues or PRs
- **Preserve user input**: When updating after meeting, keep discussion notes verbatim
- **Keep it organized**: Clear sections, consistent formatting, ticket references
- **Real work only**: Only document what was actually completed/planned

## Output Structure

Retrospective must include these sections:
- Sprint X Review (completed, in progress, not started)
- Retrospective Discussion (went well, improve, actions, blockers)
- Sprint X+1 Preview (goal, planned work, decisions)

## References

- [Retro Template](references/retro-template.md) - Default document structure
