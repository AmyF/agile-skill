#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="${1:-$(pwd)}"; SKILLS_DIR="${ROOT_DIR}/.claude/skills"; fail(){ echo "ERROR: $1" >&2; exit 1; }
[ -f "$ROOT_DIR/README.md" ] || fail README; [ -f "$ROOT_DIR/CHANGELOG.md" ] || fail CHANGELOG; [ -f "$ROOT_DIR/LICENSE" ] || fail LICENSE; [ -d "$ROOT_DIR/docs" ] || fail docs; [ -d "$SKILLS_DIR" ] || fail skills
for forbidden in .agile .github examples schemas scripts; do [ ! -e "$ROOT_DIR/$forbidden" ] || fail "forbidden root path exists: $forbidden"; done
for skill in agile-run agile-prd agile-ddd agile-fid agile-tdd agile-acceptance agile-recovery agile-git agile-github; do [ -f "$SKILLS_DIR/$skill/SKILL.md" ] || fail "$skill/SKILL.md missing"; grep -q '^name:' "$SKILLS_DIR/$skill/SKILL.md" || fail "$skill name missing"; grep -q '^description:' "$SKILLS_DIR/$skill/SKILL.md" || fail "$skill description missing"; done
if grep -RInE 'gh issue create|gh pr create|gh project|auto_create|auto_update|auto_close|sync_fields|last_synced_at' "$SKILLS_DIR/agile-github" >/tmp/agile_github_api_matches.txt 2>/dev/null; then cat /tmp/agile_github_api_matches.txt >&2; fail "GitHub API automation references found"; fi
echo "[agile-skill] release readiness check passed"
