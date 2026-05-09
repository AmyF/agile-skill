---
name: agile-run
description: Orchestrate Claude-compatible app and game development with a .agile source of truth. Use when initializing agile runtime, classifying app/game work, creating features or stories, drafting PRD/FID/Acceptance artifacts, coordinating TDD/BDD, running automatic gates, recording evidence, handling change requests, preparing Git/PR/release readiness, or recovering workflow state.
---

# Agile Run Skill

## Purpose
Run an end-to-end app/game development workflow. Own `.agile` runtime state, quality profile selection, automatic gates, traceability, evidence, Change Requests, recovery records, release readiness, and handoff to expert skills.

## Operating Model
Treat `.agile` as the source of truth. Use machine gates to advance work when validation passes. Ask for human confirmation only for semantic approvals, waivers, high-risk changes, release approval, or policy exceptions. Do not approve your own product meaning.

## Required References
Load only the references needed for the task:

- `workflow-overview.md` for the app/game flow and artifact order.
- `profiles.md` for app vs game quality gates.
- `automation-gates.md` for automatic gate policy and waiver rules.
- `traceability-rules.md` for required machine-readable links.
- `artifact-authoring.md` for concise PRD, DDD, FID, and Acceptance expectations.
- `state-machine.yaml`, `approvals.yaml`, `naming-rules.md`, `release-policy.md`, and `mid-workflow-change.md` when changing runtime state.

## Workflow
1. Classify the work as `app` or `game`, set risk, and initialize `.agile` if missing.
2. Create or update feature/story runtime files before drafting implementation details.
3. Put Acceptance Criteria in PRD/Story before FID and TDD.
4. Require DDD only when risk or domain complexity demands it; otherwise record a waiver.
5. Use `agile-tdd` for TDD/BDD, app UI tests, game loop tests, playtest scenarios, and evidence mapping.
6. Use `agile-git` for branch, commit, PR, release, hotfix, and rollback workflow.
7. Run schema, placeholder, traceability, evidence, and profile gates before declaring work ready.

## Forbidden Actions
Do not self-approve, infer approval, approve `latest`, modify approved versioned artifacts in place, silently overwrite `.agile`, bypass failed gates, generate `.github` files directly, call GitHub APIs, or silently apply semantic changes after approval.
