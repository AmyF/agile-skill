# agile-skill

`agile-skill` is a Claude Skills package for AI-assisted agile workflow management.

It provides structured workflow support for PRD, DDD, FID, TDD, BDD, Acceptance evidence, Change Requests, Recovery, Git workflow, and optional file-based GitHub integration.

The target project's `.agile` directory is always the workflow source of truth. GitHub, Git, CI, and external trackers may provide collaboration surfaces or evidence, but they do not replace `.agile`.

## Skills

| Skill | Purpose |
|---|---|
| `agile-run` | Workflow orchestration, `.agile` runtime, state machine, approvals, validation, Change Requests |
| `agile-prd` | PRD drafting and review |
| `agile-ddd` | DDD drafting and review |
| `agile-fid` | FID drafting and review |
| `agile-tdd` | TDD and BDD drafting and review |
| `agile-acceptance` | Acceptance documents, evidence review, verification matrix |
| `agile-recovery` | Recovery, rollback impact, invalid state repair, revalidation planning |
| `agile-git` | Git branch, commit, PR, merge, release, hotfix, and rollback workflow |
| `agile-github` | Optional file-based GitHub templates and workflow files |

## Core Principles

```text
.agile is the source of truth.
AI must not self-approve.
Approved artifacts are immutable.
latest files are not approval targets.
Semantic changes to approved artifacts require Change Request.
BDD belongs to TDD.
GitHub integration is optional and file-based.
```

## Runtime Structure

```text
.agile/
├── agile.yaml
├── status.yaml
├── feature-index.md
├── decision-log.md
├── recovery-log.md
├── changes/
├── features/
└── releases/
```

Schemas and scripts remain inside the skill package and are not copied into `.agile`.

## GitHub Integration

`agile-github` only generates local files such as `.github/pull_request_template.md`, `.github/ISSUE_TEMPLATE/*.yml`, `.github/workflows/agile-gate.yml`, and configuration templates. It does not call GitHub APIs.
