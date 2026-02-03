# Pull Request Template

## Default PR Body Structure

```markdown
## Description

[Brief summary of what this PR does and why it's needed]

## Changes

- Key change or feature 1
- Key change or feature 2
- Key change or feature 3

## Jira Reference

[Refs|Fixes|Closes]: [TICKET-XXX](https://instance.atlassian.net/browse/TICKET-XXX)

## Testing

- [ ] Unit tests added/updated
- [ ] Manual testing completed
- [ ] No breaking changes

## Checklist

- [ ] Code follows project conventions (CONTRIBUTING.md)
- [ ] Documentation updated if needed
- [ ] PR title follows Conventional Commits format
- [ ] Linked to Jira ticket
- [ ] Branch name follows convention
```

## Jira Reference Options

### Refs (Links to ticket, doesn't close)
Use when PR is related work but doesn't complete the ticket:
```markdown
Refs: [CTA-350](https://netfeasa.atlassian.net/browse/CTA-350)
```

### Fixes (Closes ticket on merge)
Use when PR resolves a bug ticket:
```markdown
Fixes: [CTA-356](https://netfeasa.atlassian.net/browse/CTA-356)
```

### Closes (Closes ticket on merge)
Use when PR completes a feature/story ticket:
```markdown
Closes: [CTA-303](https://netfeasa.atlassian.net/browse/CTA-303)
```

## Description Guidelines

**Good description**:
```markdown
## Description

Implements offline sync queue management for the Expo app. When network is unavailable, 
user actions are queued locally and automatically synced when connection is restored.
```

**Poor description**:
```markdown
## Description

Added some code for syncing stuff.
```

**Rules**:
- Explain WHAT the PR does
- Explain WHY it's needed
- Keep it 2-4 sentences
- Focus on user-facing or system impact

## Changes Section

List the key technical changes:
- New files or components
- Modified core functionality
- Deleted deprecated code
- Configuration changes

**Good example**:
```markdown
## Changes

- Added `OfflineQueueManager` service for handling queued operations
- Implemented SQLite persistence layer for queue storage
- Updated `AuthService` to use queue when offline
- Added unit tests for queue manager (95% coverage)
```

**Poor example**:
```markdown
## Changes

- Fixed typos
- Updated comments
- Refactored some stuff
```

## Testing Section

Document what testing was done:
- Unit tests created/updated
- Integration tests
- Manual testing scenarios
- Edge cases verified

**Example**:
```markdown
## Testing

- [ ] Unit tests added for `OfflineQueueManager` (23 new tests)
- [ ] Manual testing: Verified sync works after network reconnection
- [ ] Tested edge case: Queue overflow with 10,000+ items
- [ ] No breaking changes to existing auth flow
```

## Checklist Usage

Standard checklist items to verify before submitting:
- Code follows team conventions
- Documentation updated (README, comments, architecture docs)
- PR title is Conventional Commits format
- Jira ticket linked
- Branch name follows pattern

Check items off as you complete them:
```markdown
- [x] Code follows project conventions
- [x] Documentation updated
- [x] PR title follows format
- [ ] Waiting on final review
```

## When to Use Draft PRs

Mark as draft when:
- Work is incomplete but you want early feedback
- Blocked on external dependency
- WIP that shouldn't be merged yet

Remove draft status when ready for final review and merge.

## Project-Specific Additions

Check if project has custom `.github/pull_request_template.md`:
- If exists, use that template instead of this default
- Preserve all required sections from project template
- Add any project-specific checklist items
