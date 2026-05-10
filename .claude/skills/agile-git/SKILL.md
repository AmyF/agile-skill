---
name: agile-git
description: Define and validate Git workflow for agile-run app/game projects. Use for branch naming, commit messages, PR metadata, merge gates, release branches, hotfix branches, rollback commits, and linking Git refs to .agile traceability.
---

# Agile Git Skill

## Purpose
Own Git workflow and the Git side of traceability. Ensure branches, commits, PR bodies, release branches, hotfixes, and rollbacks reference `.agile` feature/story/change/release IDs.

## Required References
Use `references/git-workflow.md`, `branch-naming.md`, `commit-message.md`, `pull-request-rules.md`, `merge-gates.md`, `release-branches.md`, `hotfix-branches.md`, and `rollback.md` as needed.

## Controlled Automation
Use scripts in `scripts/` instead of ad hoc Git commands when automation is requested:
- `checkout-branch.sh <repo> <type> <agile-id> <slug> [base] [--traceability <file>] [--dry-run]`
- `commit-agile.sh <repo> <commit-type> <agile-id> <summary> --all|--paths <path>... [--traceability <file>] [--dry-run]`
- `push-branch.sh <repo> [--dry-run]`
- `record-git-ref.py <traceability.yaml> branch|commit|pull_request|issue|merge_commit|merge_method <value>`

Automation must stop for dirty worktree conflicts, detached HEAD, invalid branch or commit metadata, ambiguous base branches, failed gates, or destructive operations.

## Forbidden Actions
Do not approve merges, bypass review, fabricate `.agile` approvals, generate `.github`, call direct GitHub APIs, or treat GitHub as source of truth.
