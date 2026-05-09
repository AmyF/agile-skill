---
name: agile-github
description: Generate optional file-based GitHub integration for agile-run projects. Use when asked to create local .github PR templates, Issue templates, Issue/PR workflow files, GitHub Actions gates, branch protection templates, or Project field templates. This skill never calls GitHub APIs.
---

# Agile GitHub Skill

## Purpose
Generate optional local `.github` files that mirror `.agile` metadata and gates. GitHub is a collaboration surface only; `.agile` remains source of truth.

## Modes
Disabled; PR template only; Issue templates only; Issue templates + PR template + Issue/PR workflow; plus optional GitHub Actions and Project field template.

## Forbidden Actions
Do not call GitHub APIs or use GitHub CLI commands to create, synchronize, close, or mutate remote GitHub objects. Do not overwrite existing `.github` files without explicit permission.
