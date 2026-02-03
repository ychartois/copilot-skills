# Daily Update Output Template

## Required Format

```markdown
## Daily Update — {{Day}}, {{Month}} {{Date}}, {{Year}}

**Yesterday:**  
- [PR #XXX] - Brief description (Jira-XXX) (Status)
- [Jira-XXX] - Brief description and status
- Major commits grouped by ticket
- Bugs/issues identified
- PR Reviewed: 
  - [PR #XXX] - Brief description (Jira-XXX)
  - [PR #XXX] - Brief description (Jira-XXX)

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

## Example Output

```markdown
## Daily Update — Friday, January 30, 2026

**Yesterday:**  
- [PR #112](https://github.com/Net-Feasa-Limited/ControlTower-Anywhere/pull/112) - Reviewed and approved API testing documentation (CTA-305)
- [PR #111](https://github.com/Net-Feasa-Limited/ControlTower-Anywhere/pull/111) - Reviewed and approved CI testing workflow (CTA-290)
- [CTA-350](https://netfeasa.atlassian.net/browse/CTA-350) - Completed Expo/Electron migration Phase 4 (4 commits)
- [CTA-305](https://netfeasa.atlassian.net/browse/CTA-305) - Completed testing documentation
- Identified bugs: CTA-357, CTA-356, CTA-355

**Today:** 
- Sync with Derek on project status
- [CTA-303](https://netfeasa.atlassian.net/browse/CTA-303) - Continue Expo migration
- [CTA-354](https://netfeasa.atlassian.net/browse/CTA-354) - Complete all screens in Expo
- Address bugs CTA-355, CTA-356, CTA-357

**Blockers:**  
None

**Notes:**  
- CTA-350 in Need Review status, awaiting team review
- Expo migration showing good progress, 3 bugs discovered during testing
```

## Section Guidelines

### Yesterday
- **Focus**: What was actually completed
- **Include**: Merged PRs, closed tickets, major commits, bugs found
- **Format**: `[Item] - Description (Ticket)`
- **Skip**: Minor commits, typo fixes, WIP that didn't complete
- **Group**: Multiple commits on same ticket into one line

### Today
- **Focus**: What's planned next
- **Include**: Active tickets, planned PRs, scheduled meetings
- **Format**: `[Ticket] - Brief work description`
- **Keep short**: 3-5 items maximum
- **Actionable**: Clear what will be worked on

### Blockers
- **Focus**: Active impediments to progress
- **Default**: "None" if no blockers
- **Be specific**: What's blocked and why
- **Actionable**: What's needed to unblock

### Notes
- **Focus**: Context that doesn't fit elsewhere
- **Include**: Time-sensitive items, important decisions, discoveries
- **Optional**: Can be brief or omitted if nothing notable
- **No speculation**: Only facts and observations

## Linking Guidelines

### Jira Tickets
```markdown
[CTA-350](https://netfeasa.atlassian.net/browse/CTA-350)
```
Format: `[TICKET-ID](https://instance.atlassian.net/browse/TICKET-ID)`

### GitHub PRs
```markdown
[PR #112](https://github.com/owner/repo/pull/112)
```
Format: `[PR #NUMBER](https://github.com/owner/repo/pull/NUMBER)`

### Commits (if referenced)
```markdown
commit 10c70702
```
Format: First 8 characters of SHA, no link needed

## Content Rules

1. **No emojis**: Never use ✅ ❌ 🚀 or any other emojis
2. **Concise**: One line per item, brief descriptions
3. **Action-oriented**: Focus on deliverables, not activities
4. **Meaningful only**: Skip implementation details, focus on what shipped
5. **Real data**: All items must come from actual Jira/GitHub queries
6. **Links required**: Every ticket/PR must have clickable link

## Validation Checks

Before finalizing output:
- [ ] Date header present: `## Daily Update — Day, Month Date, Year`
- [ ] All four sections present: Yesterday, Today, Blockers, Notes
- [ ] At least one link in Yesterday section (unless truly no activity)
- [ ] No emojis anywhere in document
- [ ] Each item has ticket/PR reference where applicable
- [ ] Blockers section has content (even if "None")
- [ ] Notes section has content (even if brief)
