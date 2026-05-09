---
name: agile-run-auto
description: Automatically advance an agile-run app/game workflow after requirements are already clear. Use when the user explicitly asks for automatic execution, autopilot, or continuing an approved/clear agile-run feature through artifacts, traceability, evidence, and gates. This skill is a thin entrypoint that reuses agile-run rules, schemas, templates, and scripts.
---

# Agile Run Auto Skill

## Purpose
Run the automatic execution mode for `agile-run`. Use this only after the goal, acceptance criteria, target profile, risk, and implementation intent are clear enough to act without more product discovery.

## Required Kernel
Load and obey `../agile-run/SKILL.md` plus only the `agile-run` references needed for the current task. Do not define separate schemas, templates, scripts, state rules, or GitHub behavior in this skill.

## Automation Loop
1. Confirm `.agile` exists or initialize it with `agile-run` scripts.
2. Create or update feature/story runtime records, concise artifacts, traceability, and evidence using `agile-run` templates.
3. Use `agile-tdd` for TDD/BDD and evidence mapping when test design is needed.
4. Use `agile-git` for branch, commit, PR, release, hotfix, or rollback metadata.
5. Run `agile-run` validation and gate scripts after each meaningful batch of changes.
6. Continue automatically only while gates are machine-verifiable and requirements remain unambiguous.

## Stop Conditions
Stop and ask the user when there is ambiguous product intent, semantic approval, waiver approval, high-risk DDD judgment, Change Request approval, release approval, failed gates that cannot be fixed mechanically, destructive actions, external credentials, or policy exceptions.

## Forbidden Actions
Do not self-approve, create a second workflow implementation, bypass `agile-run`, duplicate schemas/templates/scripts, call GitHub APIs, silently waive gates, or continue after a stop condition.
