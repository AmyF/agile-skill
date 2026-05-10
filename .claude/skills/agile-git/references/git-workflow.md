# Git Workflow

Branch format: `{type}/{agile-id}/{slug}`. Commit format: `{type}({agile-id}): {summary}`. PRs must reference `.agile` artifact paths, gate evidence, and traceability refs. Git is a delivery surface; `.agile` remains source of truth.

Use `checkout-branch.sh`, `commit-agile.sh`, `push-branch.sh`, and `record-git-ref.py` for controlled automation. Pass `--traceability <file>` when branch or commit refs should be written during checkout or commit. Stop on dirty worktree conflicts, detached HEAD, invalid branch or commit metadata, ambiguous base branch, failed gates, or destructive operations.
