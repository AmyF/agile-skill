#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: merge-pr.sh <repo> <pr-number> [--method squash|merge|rebase] [--traceability <file>] [--approved] [--ci-waived] [--dry-run]" >&2
}

REPO="${1:-}"
PR_NUMBER="${2:-}"
shift 2 2>/dev/null || { usage; exit 2; }
METHOD="squash"
TRACEABILITY=""
APPROVED=false
CI_WAIVED=false
DRY_RUN=false

while [ "$#" -gt 0 ]; do
  case "$1" in
    --method) METHOD="${2:-}"; shift 2 ;;
    --traceability) TRACEABILITY="${2:-}"; shift 2 ;;
    --approved) APPROVED=true; shift ;;
    --ci-waived) CI_WAIVED=true; shift ;;
    --dry-run) DRY_RUN=true; shift ;;
    *) usage; exit 2 ;;
  esac
done

case "${METHOD}" in squash|merge|rebase) ;; *) usage; exit 2 ;; esac
[ -n "${REPO}" ] && [ -n "${PR_NUMBER}" ] || { usage; exit 2; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
. "${SCRIPT_DIR}/github-common.sh"

require_controlled_mode "${REPO}"
run_agile_gates "${REPO}" "${SCRIPT_DIR}" >/dev/null
if [ -z "${TRACEABILITY}" ]; then
  TRACEABILITY="$(traceability_for_pr "${REPO}" "${PR_NUMBER}")"
fi
if [ "${APPROVED}" != true ] && ! has_merge_approval "${REPO}"; then
  echo "ERROR: merge requires merge_approval/release_approval in .agile or --approved for current-turn explicit approval" >&2
  exit 1
fi

if [ "${DRY_RUN}" = true ]; then
  [ "${CI_WAIVED}" = true ] || echo "cd ${REPO} && gh pr checks ${PR_NUMBER} --fail-fast"
  echo "cd ${REPO} && gh pr merge ${PR_NUMBER} --${METHOD}"
  [ -z "${TRACEABILITY}" ] || echo "record merge method ${METHOD} in ${TRACEABILITY}"
  exit 0
fi

require_gh_auth "${REPO}"
if [ "${CI_WAIVED}" != true ]; then
  (cd "${REPO}" && gh pr checks "${PR_NUMBER}" --fail-fast)
fi
(cd "${REPO}" && gh pr merge "${PR_NUMBER}" "--${METHOD}")
if [ -n "${TRACEABILITY}" ]; then
  record_git_ref "${SCRIPT_DIR}" "${TRACEABILITY}" merge_method "${METHOD}"
  MERGE_COMMIT="$(cd "${REPO}" && gh pr view "${PR_NUMBER}" --json mergeCommit --jq '.mergeCommit.oid // empty')" || MERGE_COMMIT=""
  [ -z "${MERGE_COMMIT}" ] || record_git_ref "${SCRIPT_DIR}" "${TRACEABILITY}" merge_commit "${MERGE_COMMIT}"
fi
echo "[agile-github] PR merged: ${PR_NUMBER}"
