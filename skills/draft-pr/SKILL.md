---
name: draft-pr
description: 'Create pull request drafts with proper title, description, and Jira references. Use when asked to draft PR, create pull request, open PR, prepare PR description, or format PR. Validates Conventional Commits format, checks for Jira ticket references, and follows project conventions from CONTRIBUTING.md.'
license: Apache-2.0
metadata:
  author: yannig
  version: "1.0"
allowed-tools: mcp_github_github_create_pull_request mcp_github_github_get_me Read Bash(git:*)
---

# Draft Pull Request

Creates pull request drafts following project conventions with validated title format, Jira references, and proper structure. Enforces Conventional Commits and team standards.

## When to Use This Skill

- User requests: "draft a PR", "create pull request", "open PR for current branch"
- User wants PR description generated from commits
- User needs to prepare PR following team conventions
- User wants validation of PR title and body format

## Configuration Loading

1. **Check for project config**: Read `.github/skills/draft-pr/config.md` in current workspace
2. **Required config values**:
   - Ticket Prefix (e.g., `CTA-`)
   - Branch Pattern (regex for validation)
   - CONTRIBUTING.md path
   - PR Check Workflow path (for reference)
3. **If config not found**: Look for values in `.github/copilot-instructions.md` or CONTRIBUTING.md
4. **If still not found**: Ask user for these values

## Prerequisites

- Git repository with remote configured
- Current branch has commits to PR
- Branch name follows project convention (contains Jira ticket)
- MCP GitHub server connected

## Workflow

### Step 1: Ask Questions First (CRITICAL)

**Never assume context. Always ask:**
- Which branch should this PR merge into? (base branch)
- Is this ready for review or should it be a draft?
- Any special context to include in description?
- Should I create the PR now or just show you the draft?

**Wait for user's answers before proceeding.**

### Step 2: Extract Git Context

Run git commands to collect context:

```bash
# Get current branch name
git branch --show-current

# Get commits not in base branch
git log origin/main..HEAD --oneline

# Get changed files summary
git diff --stat origin/main...HEAD

# Check for uncommitted changes
git status --porcelain
```

Extract:
- Current branch name
- Jira ticket from branch name (extract using ticket prefix pattern)
- List of commits with messages
- Changed files list
- Uncommitted changes (warn if present)

### Step 3: Validate Branch Name

Check branch name matches pattern from config (e.g., `^[a-zA-Z0-9_-]+_CTA-\d+_[a-z0-9_-]+$`):

```
Expected format: <parentBranch>_TICKET-XXX_<description>
Examples:
  - main_CTA-350_expo-migration
  - dev_CTA-27_update-planning
```

If branch doesn't match pattern:
- **WARN** user but allow to proceed
- Suggest correct format for future branches
- Note that pr-check.yml may flag this

### Step 4: Generate PR Title

**Format**: `<type>(<scope>): <description>`

Rules:
- **Type**: Extract from commits or ask user (feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert)
- **Scope**: Optional, use ticket number or feature area
- **Description**: Start with lowercase, concise summary of changes

**Examples**:
- `feat(expo): implement offline queue management`
- `fix(auth): resolve token refresh issue`
- `docs: update architecture diagrams`

If unclear from commits, ask user for type and summary.

### Step 5: Generate PR Body

Use project's PR template if `.github/pull_request_template.md` exists, otherwise use this structure:

```markdown
## Description

[Brief summary of what this PR does and why]

## Changes

- Key change 1
- Key change 2
- Key change 3

## Jira Reference

[Refs|Fixes|Closes]: [TICKET-XXX](https://instance.atlassian.net/browse/TICKET-XXX)

## Testing

- [ ] Unit tests added/updated
- [ ] Manual testing completed
- [ ] No breaking changes

## Checklist

- [ ] Code follows project conventions
- [ ] Documentation updated if needed
- [ ] PR title follows Conventional Commits format
- [ ] Linked to Jira ticket
```

**Jira Reference Rules**:
- Use extracted ticket from branch name
- Format: `Refs: CTA-XXX` (links to ticket)
- Or: `Fixes: CTA-XXX` / `Closes: CTA-XXX` (closes ticket on merge)
- Must include full Atlassian URL

### Step 6: Validate PR Requirements (REQUIRED)

Run validation script:
```bash
~/.copilot/skills/draft-pr/scripts/validate-pr.sh
```

Pass as environment variables:
```bash
export PR_TITLE="feat(expo): implement offline sync"
export PR_BODY="<content>"
export BRANCH_NAME="main_CTA-350_offline-sync"
export TICKET_PREFIX="CTA-"
export BRANCH_PATTERN="^[a-zA-Z0-9_-]+_CTA-\d+_[a-z0-9_-]+$"

~/.copilot/skills/draft-pr/scripts/validate-pr.sh
```

**Validation must pass before creating PR.**

If validation fails:
1. Show errors to user
2. Fix issues based on validator output
3. Re-validate
4. Do not proceed until validation passes

### Step 7: Present Draft to User

Show complete draft:
```
Title: <generated-title>

Body:
<generated-body>

Base Branch: <base-branch>
Head Branch: <current-branch>
Draft: <true/false>
```

Ask user:
- "Does this look correct?"
- "Should I create the PR now?"
- "Any changes needed?"

### Step 8: Create PR (Only if User Confirms)

If user approves, use MCP to create PR:

```javascript
mcp_github_github_create_pull_request({
  owner: "<from-config>",
  repo: "<from-config>",
  title: "<validated-title>",
  body: "<validated-body>",
  head: "<current-branch>",
  base: "<base-branch>",
  draft: <true/false>
})
```

Provide user with PR URL after creation.

## Stop Rules (CRITICAL)

1. **Uncommitted Changes**: If `git status` shows uncommitted changes:
   - STOP and warn user
   - Ask: "You have uncommitted changes. Commit them first or stash?"
   - Do not create PR with dirty working directory

2. **No Jira Ticket in Branch**: If cannot extract ticket from branch name:
   - STOP and ask user for ticket number
   - Warn that branch naming convention not followed

3. **Validation Fails**: If PR title/body validation fails:
   - STOP and show validation errors
   - Fix errors and re-validate
   - Do not create PR until validation passes

4. **User Hasn't Confirmed**: Never create PR without explicit user approval:
   - Always show draft first
   - Wait for user's "yes" / "create it" / "go ahead"

5. **Missing Context**: If user request is ambiguous:
   - STOP and ask clarifying questions
   - Don't assume base branch, draft status, or other details

## General Rules (Your Work Style)

- **Ask questions first**: Never assume context, always clarify before proceeding
- **Keep changes minimal**: Focus on the specific feature/fix, avoid scope creep
- **Follow conventions**: Check CONTRIBUTING.md and pr-check.yml requirements
- **Real work only**: PR body reflects actual changes, not planned work
- **Wait for confirmation**: User decides when to create PR, not the agent

## Validation Requirements

PR must pass these checks:
- ✅ Title follows Conventional Commits (`<type>(<scope>): <description>`)
- ✅ Description starts with lowercase
- ✅ Body contains Jira reference (`Refs: TICKET-XXX`)
- ✅ Branch name follows pattern (warning if not, but not blocking)
- ✅ No uncommitted changes in working directory
- ✅ All required sections present in body

## References

- [PR Template](references/pr-template.md) - Default body structure
- [Conventional Commits Guide](references/conventional-commits.md) - Title format rules
