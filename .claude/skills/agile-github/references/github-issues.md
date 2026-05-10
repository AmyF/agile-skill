# GitHub Issues

Create or update Issues with `scripts/create-issue.sh <repo> <agile-artifact> [--issue <number>] [--dry-run]`.

The script requires `integrations.github.mode: gh_controlled`, passing local gates, and authenticated `gh` for real mutation. Issue IDs or URLs must be recorded back into `.agile` traceability when a traceability file exists.

Close Issues only with `scripts/close-issue.sh`, after merge/release acceptance and explicit approval.
