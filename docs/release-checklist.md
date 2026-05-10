# Release Checklist

- [ ] Root contains README, CHANGELOG, LICENSE, docs, and `.claude/skills`.
- [ ] Root does not contain `.agile`, `.github`, examples, root schemas, or root scripts.
- [ ] Skills are limited to `agile-run`, `agile-run-auto`, `agile-tdd`, `agile-git`, and `agile-github`.
- [ ] Each skill has concise `SKILL.md` frontmatter.
- [ ] `agile-run` has strict runtime schemas for agile, status, feature, story, traceability, evidence, release, and change request records.
- [ ] `agile-run-auto` has no duplicate schemas, templates, or scripts.
- [ ] GitHub remote mutation is limited to controlled `gh` scripts under `agile-github/scripts`.
- [ ] Direct GitHub API/token automation is absent.
