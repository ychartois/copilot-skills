# Copilot Skills

Custom GitHub Copilot skills for enhanced workflow automation across projects.

## Overview

This repository contains reusable Copilot skills that integrate with Jira and GitHub to automate common development workflows.

## Skills

### 📊 Daily Update Generator (`daily-update`)

Generates concise daily status updates by querying actual Jira and GitHub activity.

**Use cases:**
- Daily standup reports
- Weekly progress summaries
- Work status documentation

**Commands:**
- `/generate-update today` - Today's work
- `/generate-update yesterday` - Yesterday's work
- `/generate-update week` - Weekly summary

**Requirements:**
- Jira MCP server configured
- GitHub MCP server configured
- Project-specific config in `.github/skills/daily-update/config.md`

### 🔀 Draft PR (`draft-pr`)

Creates pull request drafts with proper formatting, Jira references, and team conventions.

**Use cases:**
- Creating PRs that follow Conventional Commits
- Auto-linking Jira tickets
- Following team PR guidelines

**Commands:**
- `/draft-pr` - Create PR from current branch

**Requirements:**
- GitHub MCP server configured
- Project CONTRIBUTING.md
- Project-specific config in `.github/skills/draft-pr/config.md`

## Installation

### On First Machine

```bash
# This directory should already exist as your working copy
cd ~/.copilot
git init
git add .
git commit -m "Initial commit"
git remote add origin git@github.com:ychartois/copilot-skills.git
git branch -M main
git push -u origin main
```

### On Additional Machines

```bash
# Clone to home directory
cd ~
git clone git@github.com:ychartois/copilot-skills.git .copilot
```

## Configuration

Each skill requires project-specific configuration. Place config files in your project's `.github/skills/<skill-name>/config.md`.

**Example structure:**
```
your-project/
├── .github/
│   ├── copilot-instructions.md
│   └── skills/
│       ├── daily-update/
│       │   └── config.md
│       └── draft-pr/
│           └── config.md
```

See individual skill documentation for required configuration values.

## MCP Servers

These skills require Model Context Protocol (MCP) servers:

- **Atlassian MCP** - For Jira integration
- **GitHub MCP** - For GitHub API access

Configure these in your VS Code settings or Copilot configuration.

## License

Apache-2.0 (see individual skill LICENSE.txt files)

## Author

Yannig Chartois

---

*Last updated: February 3, 2026*
