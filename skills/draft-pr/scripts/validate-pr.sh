#!/bin/bash
# validate-pr.sh
# Validates PR title and body follow project conventions
# Usage: Set PR_TITLE, PR_BODY, BRANCH_NAME, TICKET_PREFIX, BRANCH_PATTERN env vars, then run

set -e

errors=0

# Check required environment variables
if [ -z "$PR_TITLE" ]; then
  echo "❌ PR_TITLE environment variable not set"
  exit 1
fi

if [ -z "$PR_BODY" ]; then
  echo "❌ PR_BODY environment variable not set"
  exit 1
fi

# Validate PR title follows Conventional Commits
if ! echo "$PR_TITLE" | grep -qE '^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\(.+\))?: [a-z].+'; then
  echo "❌ PR title must follow Conventional Commits format"
  echo "   Format: <type>(<scope>): <description starting with lowercase>"
  echo "   Types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert"
  echo "   Got: $PR_TITLE"
  ((errors++))
fi

# Validate PR body contains Jira reference
if ! echo "$PR_BODY" | grep -qE '(Refs|Fixes|Closes):\s*(\[)?[A-Z]+-[0-9]+'; then
  echo "❌ PR body must include a Jira ticket reference"
  echo "   Format: 'Refs: TICKET-XXX' or 'Fixes: TICKET-XXX' or 'Closes: TICKET-XXX'"
  ((errors++))
fi

# Validate branch name if provided (warning only)
if [ -n "$BRANCH_NAME" ] && [ -n "$BRANCH_PATTERN" ]; then
  if ! echo "$BRANCH_NAME" | grep -qE "$BRANCH_PATTERN"; then
    echo "⚠️  Warning: Branch name does not follow convention"
    echo "   Expected pattern: $BRANCH_PATTERN"
    echo "   Got: $BRANCH_NAME"
    echo "   (Not blocking, but pr-check.yml may flag this)"
  fi
fi

if [ $errors -gt 0 ]; then
  echo ""
  echo "❌ Validation failed with $errors error(s)"
  echo ""
  echo "Required format:"
  echo "  Title: <type>(<scope>): <description>"
  echo "  Body must contain: Refs: TICKET-XXX"
  exit 1
fi

echo "✅ PR validation passed"
exit 0
