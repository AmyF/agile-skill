# agile-skill

`agile-skill` is a Claude-compatible Skills package for AI-assisted app and game development.

It provides an App/Game agile development workflow with `.agile` as the source of truth, automatic machine gates, risk-based DDD, TDD/BDD, acceptance evidence, Git workflow, and optional file-based GitHub integration.

## Skills

| Skill | Purpose |
|---|---|
| `agile-run` | Main app/game workflow kernel: discussion, planning, `.agile` runtime, profiles, artifacts, gates, traceability, evidence, Change Requests, recovery, and release readiness |
| `agile-run-auto` | Thin automatic execution mode that reuses `agile-run` and advances clear requirements through artifacts, traceability, evidence, and gates until a stop condition |
| `agile-tdd` | TDD/BDD, app UI/integration tests, game loop/rule tests, playtest evidence, regression coverage, and evidence mapping |
| `agile-git` | Branch, commit, PR, merge, release, hotfix, and rollback workflow aligned to `.agile` artifacts |
| `agile-github` | Optional local `.github` templates and workflow files; no GitHub API automation |

## Core Principles

```text
.agile is the source of truth.
Automatic gates verify machine-checkable work.
AI must not self-approve semantic meaning, waivers, or releases.
Approved artifacts are immutable.
latest files are not approval targets.
Acceptance Criteria come before FID and TDD.
DDD is risk-based.
Traceability is a gate, not a manual matrix.
GitHub integration is optional and file-based.
```

## Runtime Structure

```text
.agile/
├── agile.yaml
├── status.yaml
├── feature-index.md
├── decision-log.md
├── changes/
├── features/
└── releases/
```

Schemas and scripts remain inside the skill package and are not copied into `.agile`.

## Workflow

```text
Intake
→ Feature PRD
→ Story + Acceptance Criteria
→ DDD if required
→ FID
→ TDD/BDD
→ Implementation
→ Acceptance Evidence
→ Git Gate
→ Release
```

The default artifact style is concise and executable: enough information for implementation, validation, and audit without creating document theater.
