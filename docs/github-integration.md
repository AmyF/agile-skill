# GitHub Integration

GitHub integration is optional and disabled by default.

Modes:

- `disabled`: no GitHub files or remote actions.
- `file_based`: generate local `.github` templates and workflow files only.
- `gh_controlled`: allow controlled GitHub CLI automation for Issues, PRs, merge, and Issue close.

Remote mutation is allowed only through `gh`, only after local gates pass, and only when `.agile/agile.yaml` sets `integrations.github.mode: gh_controlled`. Merge and Issue close also require an explicit approval record or explicit approval in the current turn.

Direct GitHub API/token automation is not part of this skill. `.agile` remains the source of truth.
