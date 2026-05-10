# GitHub Integration

GitHub integration has three modes: `disabled`, `file_based`, and `gh_controlled`.

Use `file_based` for local `.github` templates only. Use `gh_controlled` only when the user explicitly requests remote GitHub automation and `.agile/agile.yaml` records that mode.

Remote mutation must use `gh` scripts in `agile-github/scripts`, after `agile-run` gates pass. `.agile` remains source of truth.
