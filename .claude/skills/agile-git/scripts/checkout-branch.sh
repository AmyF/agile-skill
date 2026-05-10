#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: checkout-branch.sh <repo> <type> <agile-id> <slug> [base] [--traceability <file>] [--dry-run]" >&2
}

REPO="${1:-}"
TYPE="${2:-}"
AGILE_ID="${3:-}"
SLUG="${4:-}"
shift 4 2>/dev/null || { usage; exit 2; }
BASE=""
TRACEABILITY=""
DRY_RUN=false

while [ "$#" -gt 0 ]; do
  case "$1" in
    --traceability) TRACEABILITY="${2:-}"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    *)
      [ -z "${BASE}" ] || { usage; exit 2; }
      BASE="$1"
      shift
      ;;
  esac
done

[ -n "${REPO}" ] && [ -n "${TYPE}" ] && [ -n "${AGILE_ID}" ] && [ -n "${SLUG}" ] || { usage; exit 2; }
[ -d "${REPO}/.git" ] || { echo "ERROR: not a git repository: ${REPO}" >&2; exit 2; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BRANCH="$("${SCRIPT_DIR}/generate-branch-name.sh" "${TYPE}" "${AGILE_ID}" "${SLUG}")"
"${SCRIPT_DIR}/validate-branch-name.sh" "${BRANCH}" >/dev/null
CURRENT_BRANCH="$(git -C "${REPO}" branch --show-current || true)"

if [ "${DRY_RUN}" = true ]; then
  [ -n "${BASE}" ] && echo "git -C ${REPO} switch ${BASE}"
  if [ "${CURRENT_BRANCH}" = "${BRANCH}" ]; then
    echo "git -C ${REPO} switch ${BRANCH}"
  elif git -C "${REPO}" rev-parse --verify --quiet "refs/heads/${BRANCH}" >/dev/null; then
    echo "git -C ${REPO} switch ${BRANCH}"
  else
    echo "git -C ${REPO} switch -c ${BRANCH}"
  fi
  [ -z "${TRACEABILITY}" ] || echo "record branch ${BRANCH} in ${TRACEABILITY}"
  exit 0
fi

if [ -n "$(git -C "${REPO}" status --porcelain)" ]; then
  echo "ERROR: dirty worktree; commit, stash, or clean changes before checkout" >&2
  exit 1
fi

[ -n "${BASE}" ] && git -C "${REPO}" switch "${BASE}"
if [ "${CURRENT_BRANCH}" = "${BRANCH}" ] && [ -z "${BASE}" ]; then
  :
elif git -C "${REPO}" rev-parse --verify --quiet "refs/heads/${BRANCH}" >/dev/null; then
  git -C "${REPO}" switch "${BRANCH}"
else
  git -C "${REPO}" switch -c "${BRANCH}"
fi
[ -z "${TRACEABILITY}" ] || "${SCRIPT_DIR}/record-git-ref.py" "${TRACEABILITY}" branch "${BRANCH}"
echo "[agile-git] checked out ${BRANCH}"
