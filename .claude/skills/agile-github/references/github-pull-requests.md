# GitHub Pull Requests

Create PRs with `scripts/create-pr.sh <repo> <story-or-feature-artifact> [--base <base>] [--dry-run]`.

PR bodies must include `.agile` artifact paths, traceability, evidence IDs when available, and gate status. The script requires `gh_controlled`, passing local gates, and a valid current branch.

Merge only with `scripts/merge-pr.sh`, after passing gates, valid Git metadata, passing CI when available, and explicit merge or release approval. Pass `--traceability <file>` when the PR number cannot be inferred from existing traceability refs.
