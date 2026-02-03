# Conventional Commits Guide

## Format

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

## Type

Must be one of:

| Type | Description | When to Use |
|------|-------------|-------------|
| `feat` | New feature | Adding functionality users can see/use |
| `fix` | Bug fix | Fixing broken functionality |
| `docs` | Documentation only | README, comments, architecture docs |
| `style` | Code style changes | Formatting, whitespace, no logic changes |
| `refactor` | Code refactoring | Restructuring without changing behavior |
| `perf` | Performance improvement | Optimization work |
| `test` | Test updates | Adding or updating tests |
| `build` | Build system changes | Package.json, dependencies, build scripts |
| `ci` | CI/CD changes | GitHub Actions, workflows, automation |
| `chore` | Maintenance tasks | Configs, tooling, minor updates |
| `revert` | Revert previous commit | Undoing a prior change |

## Scope (Optional but Recommended)

Indicates what part of codebase is affected:

**Component/Module examples**:
- `auth` — Authentication system
- `sync` — Sync engine
- `ui` — User interface components
- `db` — Database layer
- `api` — API integration
- `offline` — Offline functionality
- `expo` — Expo-specific changes
- `electron` — Electron-specific changes

**Feature area examples**:
- `inspection` — Inspection workflow
- `alarms` — Alarm management
- `reports` — Reporting features

**Infrastructure examples**:
- `deps` — Dependencies
- `config` — Configuration
- `ci` — Continuous integration

## Description

- **Start with lowercase** (enforced)
- **Present tense imperative** ("add feature" not "added feature")
- **No period at end**
- **Concise** (50 characters or less preferred)

**Good examples**:
- `feat(sync): implement offline queue management`
- `fix(auth): resolve token refresh on app resume`
- `docs: update architecture diagrams for Expo migration`
- `refactor(db): simplify transaction handling`

**Bad examples**:
- `feat(sync): Implement offline queue management` (capital I)
- `fix(auth): Fixed the token refresh bug.` (past tense, period)
- `Update stuff` (vague, no type)
- `WIP` (not descriptive)

## Body (Optional)

Detailed explanation of what and why (not how):

```
feat(offline): add queue persistence layer

Implements SQLite-backed queue storage to persist pending operations
across app restarts. Critical for ensuring data integrity when device
is offline for extended periods.
```

## Footer (Optional)

Reference issues or breaking changes:

```
feat(api): migrate to new sync endpoint

BREAKING CHANGE: Old /sync endpoint deprecated, clients must update
to /v2/sync with new authentication header format.

Refs: CTA-350
Closes: CTA-303
```

## Breaking Changes

If PR introduces breaking changes, include in footer:

```
BREAKING CHANGE: <description of what breaks>
```

## Multiple Types

If PR contains multiple types, use most significant:
- Feature > Fix > Refactor > Docs

Or consider splitting into multiple PRs.

## Examples by Project Stage

### Feature Development
```
feat(inspection): add photo capture for damage reports
feat(offline): implement background sync scheduler
feat(ui): create alarm filtering controls
```

### Bug Fixes
```
fix(sync): prevent duplicate uploads on retry
fix(auth): handle token expiry during long sessions
fix(db): resolve foreign key constraint violation
```

### Documentation
```
docs: add API integration testing guide
docs(architecture): update offline-first data flow diagrams
docs: document Expo migration steps
```

### Refactoring
```
refactor(auth): extract token refresh logic to service
refactor(db): migrate to async/await patterns
refactor(ui): consolidate duplicate button styles
```

### Infrastructure
```
build(expo): upgrade to SDK 50
ci: add automated PR validation workflow
chore(deps): update React Native to 0.73
```

## PR Title Validation

Your PR title will be validated by `pr-check.yml`:
- ✅ Type must be from allowed list
- ✅ Scope is optional but recommended
- ✅ Description must start with lowercase
- ✅ Format must match exactly

If validation fails, GitHub Actions will comment on your PR with specific fix instructions.

## Quick Reference

```
Type:        feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert
Scope:       (optional) lowercase, in parentheses
Description: lowercase, present tense, no period, concise
```

**Template**: `type(scope): description`

**Example**: `feat(sync): implement retry logic with exponential backoff`
