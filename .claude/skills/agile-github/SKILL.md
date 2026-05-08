---
name: agile-github
description: Generate optional GitHub file-based integration for agile-skill projects. Use when the user asks to create .github templates, GitHub Issue templates, Pull Request template, Issue + PR workflow files, GitHub Actions gates, branch protection template, or GitHub Project field template. This skill does not call GitHub APIs.
---

# Agile GitHub Skill

## Purpose
Generate optional file-based GitHub integration. It creates local `.github` files and configuration templates only.

## Modes
Disabled; PR template only; Issue templates only; Issue templates + PR template + Issue/PR workflow; plus optional GitHub Actions and Project field template.

## Forbidden Actions
Do not call GitHub APIs or use GitHub CLI commands to create or synchronize remote GitHub objects. Do not overwrite existing `.github` files without explicit permission.

