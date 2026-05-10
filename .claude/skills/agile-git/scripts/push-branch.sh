#!/usr/bin/env bash
set -euo pipefail

REPO="${1:-}"
DRY_RUN=false
[ "${2:-}" != "--dry-run" ] || DRY_RUN=true

[ -n "${REPO}" ] || { echo "Usage: push-branch.sh <repo> [--dry-run]" >&2; exit 2; }
[ -d "${REPO}/.git" ] || { echo "ERROR: not a git repository: ${REPO}" >&2; exit 2; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BRANCH="$(git -C "${REPO}" branch --show-current)"
[ -n "${BRANCH}" ] || { echo "ERROR: detached HEAD cannot be pushed by agile-git" >&2; exit 1; }
"${SCRIPT_DIR}/validate-branch-name.sh" "${BRANCH}" >/dev/null

if [ "${DRY_RUN}" = true ]; then
  echo "git -C ${REPO} push -u origin ${BRANCH}"
  exit 0
fi

git -C "${REPO}" push -u origin "${BRANCH}"
echo "[agile-git] pushed ${BRANCH}"
