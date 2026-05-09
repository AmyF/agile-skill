---
name: agile-tdd
description: Design, review, and validate TDD/BDD workflows for agile-run app and game stories. Use for test strategy, TDD flows, BDD scenarios, test-light eligibility, app UI/integration tests, game loop/rule tests, playtest scenarios, regression coverage, and mapping test evidence to .agile acceptance criteria.
---

# Agile TDD Skill

## Purpose
Own test design for `agile-run` stories. Convert Acceptance Criteria into executable TDD flows, optional BDD scenarios, app/game profile checks, and evidence mappings.

## Workflow
1. Read the story, acceptance criteria, profile, risk, FID, and traceability file.
2. Create TDD flows before or alongside implementation.
3. Add BDD scenarios when behavior needs user-readable examples; BDD remains owned by TDD.
4. For `app`, include relevant unit, integration, UI, accessibility, privacy, data, or platform checks.
5. For `game`, include deterministic rules/scoring tests where possible plus playtest/feel/performance evidence where appropriate.
6. Map every TDD flow and evidence item back to Acceptance Criteria.

## Required References
Use `references/checklist.md`, `references/tdd-flow-types.md`, `references/ui-tdd-rules.md`, and templates only when drafting artifacts.

## Forbidden Actions
Do not self-approve, treat BDD as a separate primary workflow state, use test-light for high-risk behavioral changes, or mark evidence complete without linked criteria.
