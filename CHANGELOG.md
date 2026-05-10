# Changelog

## Unreleased

- Breaking: replaced the nine-skill document workflow with the `agile-run` workflow kernel plus `agile-run-auto`, `agile-tdd`, `agile-git`, and `agile-github` expert/entrypoint skills.
- Added app/game profiles, automatic machine gates, concise executable artifacts, risk-based DDD, and gate-oriented traceability/evidence.
- Tightened runtime YAML schemas for `.agile` config, status, feature, story, traceability, evidence, release, and change request records.
- Added `validate-gates` to check placeholders, schema validity, acceptance criteria, traceability, evidence, game playtest evidence, and DDD waiver requirements.
- Added opt-in controlled Git/GitHub automation through `agile-git` and GitHub CLI `gh` scripts under `agile-github`.

## 0.1.0

- Added initial Claude Skills for agile workflow management, PRD, DDD, FID, TDD, Acceptance, Recovery, Git workflow, and file-based GitHub integration.
