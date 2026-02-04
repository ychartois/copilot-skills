# Draft PR Config

**Project**: VCT Anywhere

## Required Values

- **Ticket Prefix**: `CTA-`
- **Branch Pattern**: `^[a-zA-Z0-9_-]+_CTA-\d+_[a-z0-9_-]+$`
- **GitHub Repo**: `Net-Feasa-Limited/ControlTower-Anywhere`

## Project Files

- **CONTRIBUTING.md**: `CONTRIBUTING.md`
- **PR Check Workflow**: `.github/workflows/pr-check.yml`
- **PR Template**: `.github/pull_request_template.md`

## Conventional Commit Types

Allowed types for this project:
- `feat` — New features
- `fix` — Bug fixes
- `docs` — Documentation
- `style` — Code style
- `refactor` — Refactoring
- `perf` — Performance
- `test` — Testing
- `build` — Build system
- `ci` — CI/CD
- `chore` — Maintenance
- `revert` — Revert changes

## Branch Naming Convention

Format: `<parentBranch>_CTA-XXX_<description>`

Examples:
- `main_CTA-350_expo-migration`
- `dev_CTA-27_update-planning`
- `main_CTA-355_fix-auth-bug`

## PR Validation Rules

Enforced by `.github/workflows/pr-check.yml`:
1. Title must follow Conventional Commits
2. Body must contain Jira reference (Refs/Fixes/Closes: CTA-XXX)
3. Branch name should follow pattern (warning if not)
4. Auto-labels applied based on changed files
