---
name: agile-github
description: Manage optional GitHub integration for agile-run projects. Use when asked to create local .github templates or to run controlled GitHub CLI automation for Issues, PRs, merge, and Issue close from .agile artifacts.
---

# Agile GitHub Skill

## Purpose
Generate optional local `.github` files and run controlled GitHub CLI automation. GitHub is a collaboration surface only; `.agile` remains source of truth.

## Modes
- `disabled`: no GitHub files or remote mutation.
- `file_based`: generate local `.github` templates and workflow files only.
- `gh_controlled`: allow `gh` scripts for Issue create/update, PR create, PR merge, and Issue close after required gates.

## Controlled Automation
Use scripts in `scripts/` instead of ad hoc commands:
- `create-issue.sh <repo> <agile-artifact> [--issue <number>] [--dry-run]`
- `create-pr.sh <repo> <story-or-feature-artifact> [--base <base>] [--dry-run]`
- `merge-pr.sh <repo> <pr-number> [--method squash|merge|rebase] [--traceability <file>] [--approved] [--ci-waived] [--dry-run]`
- `close-issue.sh <repo> <issue-number> [--approved] [--dry-run]`

Remote mutation requires `integrations.github.mode: gh_controlled`, authenticated `gh`, passing `agile-run` gates, and valid `.agile` traceability. Merge and Issue close require explicit approval in `.agile` or explicit current-turn approval.

## Forbidden Actions
Do not call direct GitHub APIs, use token scripts, mutate remotes outside `gh_controlled`, bypass failed gates or CI, fabricate approvals, close Issues before merge/release acceptance, or overwrite existing `.github` files without explicit permission.
