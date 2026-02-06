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

### Step 1: Gather Context (REQUIRED)

**Ask user these questions**:
1. Which sprint are we retrospecting? (e.g., Sprint 13)
2. What are the ACTUAL sprint dates? (e.g., Feb 2 - Feb 6, 2026)
3. What is the next sprint number? (e.g., Sprint 14)

**Then automatically**:
4. Calculate output filename: `docs/meetings/YYYY-MM-DD-SprintXX-YY-Retro-Planning.md`
   - YYYY-MM-DD = last day of current sprint
   - XX = current sprint number
   - YY = next sprint number
   - Example: `docs/meetings/2026-02-06-Sprint13-14-Retro-Planning.md`

5. Read previous sprint retro to track action items:
   - Look for most recent file matching pattern: `docs/meetings/*-Sprint*-Retro*.md`
   - Extract action items, risks, blockers from previous sprint

### Step 2: Query Jira for Sprint Activity

Use ACTUAL sprint dates from user (not updated field):

```jql
project = CTA 
AND (created >= "{sprint_start_date}" OR updated >= "{sprint_start_date}") 
AND updated <= "{sprint_end_date}"
ORDER BY status DESC, updated DESC
```

**Categorize by status**:
- **Done**: Status changed to Done during sprint
- **In Progress**: Currently in progress or review
- **Planned but not started**: In sprint backlog but not started

### Step 3: Query GitHub for Sprint PRs

Search across all Net-Feasa-Limited repos:

```
org:Net-Feasa-Limited is:pr merged:{sprint_start_date}..{sprint_end_date}
```

**Also get PRs in review**:
```
org:Net-Feasa-Limited is:pr state:open updated:>={sprint_start_date}
```

### Step 4: Generate Retro Document Using Template

**CRITICAL**: Must use EXACT template from `docs/meetings/RETROSPECTIVE-TEMPLATE.md`

**Pre-fill these sections** (AUTO-GENERATED):
- **Date**: Last day of sprint (YYYY-MM-DD format)
- **Jira**: Link to sprint planning ticket (CTA-XX format)
- **Sprint Goal**: Extract from sprint description or leave emoji placeholder
- **Stories/Tasks Completed**: From Jira Done tickets with subtasks listed
- **GitHub PRs Merged**: From GitHub query with full links and descriptions
- **GitHub PRs In Review**: From GitHub open PR query

**Leave BLANK for meeting discussion** (DO NOT FILL):
- Time
- Attendees
- What went well
- What didn't go well / can be improved
- New Sprint: Sprint X+1 Planning Notes
- Questions
- Decisions Made
- Action Items
- Risks/Blockers
- Sprint X+1 Preview (Goal, Planned Work)

### Step 5: Save Document

Save to: `docs/meetings/{YYYY-MM-DD}-Sprint{XX}-{YY}-Retro-Planning.md`

**Filename format example**: `2026-02-06-Sprint13-14-Retro-Planning.md`

**Use this EXACT template structure**:

```markdown
# Meeting Notes - Sprint {X} Retrospective - {Month Day, Year}

**Project**: VCT Anywhere
**Date**: YYYY-MM-DD  
**Time**: HH:MM - HH:MM  
**Type**: 🔄 Retrospective
**Jira**: [CTA-XX](https://netfeasa.atlassian.net/browse/CTA-XX)

---

## Attendees
<!-- to fill during meeting -->
- Name, Name, Name

---

## Agenda
1. Retrospective discussion (The Good / Can Be Improved)
2. Review the board
3. Create new Sprint and assign tasks
4. Questions & decisions
5. Identify blockers and risks

---

## Notes

### Retro
<!-- to fill during meeting discussion -->

#### What went well
- What went well this sprint
- Positive outcomes
- Successful practices

#### What didn't go well/ can be improved
- What could be better
- Process improvements
- Learning opportunities

### Review the board: Sprint {X} Overview
<!-- Auto-generated with /retro-sprint CTA-XX before meeting -->
**Sprint Goal**: 
- {Goal statement} [status emoji]

**Stories/Tasks Completed**:
<!-- Query Jira with: (updated >= "YYYY-MM-DD" AND updated <= "YYYY-MM-DD") AND status = Done -->
- **CTA-XX**: Story title (**Status**: 🟡 Open | 🔵 In Progress | 🟢 Done | 🔴 Blocked)
  - CTA-XX: Subtask 1 🟢 Done
  - CTA-XX: Subtask 2 🟢 Done

**GitHub PRs Merged (#)**:
<!-- Query GitHub: all authors merged:YYYY-MM-DD..YYYY-MM-DD -->
- [repo-name #XX](https://github.com/Net-Feasa-Limited/repo-name/pull/XX) - Description (CTA-XX)

**GitHub PRs In Review (#)**:
<!-- Query GitHub: all authors state:open updated:>=YYYY-MM-DD -->
- [repo-name #XX](https://github.com/Net-Feasa-Limited/repo-name/pull/XX) - Description (CTA-XX)

### Sprint X+1 Preview
<!-- to update after meeting, with /retro-update command -->
<!-- Query new sprint tickets from Jira after sprint planning -->

**Sprint Goal**: 
- Goal statement for next sprint

**Planned Work**:
- Main stories/tasks planned
- Key deliverables
- Team assignments


### Questions
<!-- Add specific questions raised during the sprint here -->
- Question 1?
- Question 2?
- Question 3?

---

## Decisions Made
<!-- to fill during meeting when team makes decisions -->
| # | Decision | Rationale | Owner | Ticket |
|---|----------|-----------|-------|--------|
| 1 | We will... | Because... | @name | CTA-XX |
| 2 | We decided not to... | Due to... | @name | - |

---

## Action Items
<!-- to fill during meeting, create Jira tickets for trackable actions -->
| # | Action | Owner | Due Date | Status | Ticket |
|---|--------|-------|----------|--------|--------|
| 1 | Do something | @name | YYYY-MM-DD | 🟡 Open | CTA-XX |
| 2 | Research X | @name | YYYY-MM-DD | 🟡 Open | - |

**Status**: 🟡 Open | 🔵 In Progress | 🟢 Done | 🔴 Blocked

---

## Risks / Blockers
<!-- Update status of previous risks, add new ones identified during sprint -->
<!-- Carry forward unresolved risks from previous sprint meeting notes -->
| # | Risk | Owner | Mitigation | Status | Ticket |
|---|------|-------|-----------|--------|--------|
| 1 | Risk description | @name | How we'll address it | 🟡 Open | CTA-XX |
| 2 | Blocker description | @name | Resolution plan | 🔴 Blocked | CTA-XX |

**Status**: 🟡 Open | 🔵 In Progress | 🟢 Done | 🔴 Blocked

---

## Next Meeting
**Date**: YYYY-MM-DD (Friday)  
**Agenda**: Sprint {X+1} retrospective and planning

---

## Attachments / References
<!-- Add links to key PRs, specs, or documentation discussed in meeting -->
- [Relevant Jira Epic](https://netfeasa.atlassian.net/browse/CTA-XX)
- [Related PR](https://github.com/Net-Feasa-Limited/ControlTower-Anywhere/pull/XX)
- [Documentation](https://github.com/Net-Feasa-Limited/ControlTower-Anywhere/tree/main/docs)

```

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
