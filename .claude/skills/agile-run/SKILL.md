---
name: agile-run
description: Orchestrate the agile-skill workflow for a target project. Use when initializing .agile, creating features or stories, checking workflow state, applying stage transitions, recording approvals, handling change requests, or recovering workflow state.
---

# Agile Run Skill

## Purpose
Coordinate workflow and own the `.agile` runtime model, state machine enforcement, approval records, traceability requirements, Change Requests, recovery entry, and handoff to other agile skills.

## When to Use
Use for initialization, feature/story creation, state checks, transitions, approval recording, Change Requests, recovery, validation, release scope, and mid-workflow requirement changes.

## Required References
Load relevant files from `references/`, especially `workflow-overview.md`, `state-machine.yaml`, `approvals.yaml`, `execution-constraints.md`, `naming-rules.md`, `traceability-rules.md`, `release-policy.md`, `schema-usage.md`, and `mid-workflow-change.md`.

## Validation Rule
After creating or modifying any `.agile` runtime YAML file, run the matching validation script. Do not report success until validation passes or clearly report validation failure.

## Forbidden Actions
Do not self-approve, infer human approval, approve `latest`, modify approved versioned artifacts in place, silently overwrite `.agile`, generate `.github`, perform Git/GitHub actions directly, or silently apply mid-workflow changes that affect approved artifacts.

