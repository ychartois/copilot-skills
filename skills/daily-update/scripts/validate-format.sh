#!/bin/bash
# validate-format.sh
# Validates daily update follows required format
# Usage: validate-format.sh <output-file>

set -e

if [ $# -eq 0 ]; then
  echo "Usage: $0 <output-file>"
  exit 1
fi

FILE="$1"
errors=0

if [ ! -f "$FILE" ]; then
  echo "❌ File not found: $FILE"
  exit 1
fi

# Check required headings exist
required_headings=("Yesterday:" "Today:" "Blockers:" "Notes:")

for heading in "${required_headings[@]}"; do
  if ! grep -q "^\*\*${heading}" "$FILE"; then
    echo "❌ Missing required heading: **${heading}**"
    ((errors++))
  fi
done

# Check for date header
if ! grep -q "^## Daily Update —" "$FILE"; then
  echo "❌ Missing date header (should start with '## Daily Update —')"
  ((errors++))
fi

# Check for at least one link (Jira or GitHub)
if ! grep -qE '\[.*\]\(http' "$FILE"; then
  echo "⚠️  Warning: No links found (expected Jira tickets or GitHub PRs)"
fi

if [ $errors -gt 0 ]; then
  echo ""
  echo "❌ Validation failed with $errors error(s)"
  echo "Required format:"
  echo "  ## Daily Update — Day, Month Date, Year"
  echo "  **Yesterday:**"
  echo "  **Today:**"
  echo "  **Blockers:**"
  echo "  **Notes:**"
  exit 1
fi

echo "✅ Format validation passed"
exit 0
