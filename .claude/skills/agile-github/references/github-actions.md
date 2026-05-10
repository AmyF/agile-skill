# GitHub Actions

GitHub Actions files may be generated in `file_based` mode as local templates. Controlled remote automation does not edit branch protection or Actions settings directly.

Merge automation must check CI with `gh pr checks --fail-fast` when checks are available, unless the user explicitly waives unknown or unavailable CI in the current turn.
