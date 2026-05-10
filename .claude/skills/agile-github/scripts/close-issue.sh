#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: close-issue.sh <repo> <issue-number> [--approved] [--dry-run]" >&2
}

REPO="${1:-}"
ISSUE_NUMBER="${2:-}"
shift 2 2>/dev/null || { usage; exit 2; }
APPROVED=false
DRY_RUN=false

while [ "$#" -gt 0 ]; do
  case "$1" in
    --approved) APPROVED=true; shift ;;
    --dry-run) DRY_RUN=true; shift ;;
    *) usage; exit 2 ;;
  esac
done

[ -n "${REPO}" ] && [ -n "${ISSUE_NUMBER}" ] || { usage; exit 2; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
. "${SCRIPT_DIR}/github-common.sh"

require_controlled_mode "${REPO}"
run_agile_gates "${REPO}" "${SCRIPT_DIR}" >/dev/null
if [ "${APPROVED}" != true ] && ! has_merge_approval "${REPO}"; then
  echo "ERROR: issue close requires merge_approval/release_approval in .agile or --approved for current-turn explicit approval" >&2
  exit 1
fi

if [ "${DRY_RUN}" = true ]; then
  echo "cd ${REPO} && gh issue close ${ISSUE_NUMBER} --comment 'Closed by agile-run controlled automation.'"
  exit 0
fi

require_gh_auth "${REPO}"
(cd "${REPO}" && gh issue close "${ISSUE_NUMBER}" --comment "Closed by agile-run controlled automation.")
echo "[agile-github] issue closed: ${ISSUE_NUMBER}"
