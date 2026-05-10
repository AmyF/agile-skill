# Permissions

Remote GitHub mutation is opt-in. Required conditions:

- `.agile/agile.yaml` sets `integrations.github.mode: gh_controlled`.
- GitHub CLI `gh` is installed and authenticated for real mutation.
- `agile-run` gates pass.
- Merge and Issue close have explicit approval in `.agile` or explicit approval in the current turn.

Do not use direct GitHub APIs, token scripts, or remote mutation from other skills.
