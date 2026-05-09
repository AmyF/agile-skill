#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="${1:-$(pwd)}"
SKILLS_DIR="${ROOT_DIR}/.claude/skills"

fail() {
  echo "ERROR: $1" >&2
  exit 1
}

[ -f "${ROOT_DIR}/README.md" ] || fail "README.md missing"
[ -f "${ROOT_DIR}/CHANGELOG.md" ] || fail "CHANGELOG.md missing"
[ -f "${ROOT_DIR}/LICENSE" ] || fail "LICENSE missing"
[ -d "${ROOT_DIR}/docs" ] || fail "docs missing"
[ -d "${SKILLS_DIR}" ] || fail ".claude/skills missing"

for forbidden in .agile .github examples schemas scripts; do
  [ ! -e "${ROOT_DIR}/${forbidden}" ] || fail "forbidden root path exists: ${forbidden}"
done

for skill in agile-run agile-run-auto agile-tdd agile-git agile-github; do
  [ -f "${SKILLS_DIR}/${skill}/SKILL.md" ] || fail "${skill}/SKILL.md missing"
  grep -q '^name:' "${SKILLS_DIR}/${skill}/SKILL.md" || fail "${skill} name missing"
  grep -q '^description:' "${SKILLS_DIR}/${skill}/SKILL.md" || fail "${skill} description missing"
done

for removed in agile-dev agile-prd agile-ddd agile-fid agile-acceptance agile-recovery; do
  [ ! -e "${SKILLS_DIR}/${removed}" ] || fail "removed skill still present: ${removed}"
done

for duplicate in schemas templates scripts references; do
  [ ! -e "${SKILLS_DIR}/agile-run-auto/${duplicate}" ] || fail "agile-run-auto must not define ${duplicate}"
done

for schema in agile status feature story traceability evidence release change-request; do
  [ -f "${SKILLS_DIR}/agile-run/schemas/${schema}.schema.json" ] || fail "schema missing: ${schema}"
done

if grep -RInE 'gh issue create|gh pr create|gh project|auto_create|auto_update|auto_close|sync_fields|last_synced_at' "${SKILLS_DIR}/agile-github" >/tmp/agile_github_api_matches.txt 2>/dev/null; then
  cat /tmp/agile_github_api_matches.txt >&2
  fail "GitHub API automation references found"
fi

echo "[agile-run] release readiness check passed"
