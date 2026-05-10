#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: create-issue.sh <repo> <agile-artifact> [--issue <number>] [--dry-run]" >&2
}

REPO="${1:-}"
ARTIFACT="${2:-}"
shift 2 2>/dev/null || { usage; exit 2; }
ISSUE_NUMBER=""
DRY_RUN=false

while [ "$#" -gt 0 ]; do
  case "$1" in
    --issue) ISSUE_NUMBER="${2:-}"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    *) usage; exit 2 ;;
  esac
done

[ -n "${REPO}" ] && [ -n "${ARTIFACT}" ] || { usage; exit 2; }
[ -f "${ARTIFACT}" ] || { echo "ERROR: artifact not found: ${ARTIFACT}" >&2; exit 2; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
. "${SCRIPT_DIR}/github-common.sh"

require_controlled_mode "${REPO}"
run_agile_gates "${REPO}" "${SCRIPT_DIR}" >/dev/null

ID="$(artifact_id "${ARTIFACT}")"
TITLE="$(artifact_title "${ARTIFACT}")"
[ -n "${ID}" ] || ID="$(basename "${ARTIFACT}")"
[ -n "${TITLE}" ] || TITLE="${ID}"
ISSUE_TITLE="[${ID}] ${TITLE}"
BODY_FILE="$(mktemp)"
cat > "${BODY_FILE}" <<EOF
Source of truth: .agile

Artifact: ${ARTIFACT}
Agile ID: ${ID}

Created by agile-run controlled GitHub automation.
EOF

if [ "${DRY_RUN}" = true ]; then
  if [ -n "${ISSUE_NUMBER}" ]; then
    printf 'cd %q && gh issue edit %q --title %q --body-file %q\n' "${REPO}" "${ISSUE_NUMBER}" "${ISSUE_TITLE}" "${BODY_FILE}"
  else
    printf 'cd %q && gh issue create --title %q --body-file %q\n' "${REPO}" "${ISSUE_TITLE}" "${BODY_FILE}"
  fi
  cat "${BODY_FILE}"
  rm -f "${BODY_FILE}"
  exit 0
fi

require_gh_auth "${REPO}"
if [ -n "${ISSUE_NUMBER}" ]; then
  (cd "${REPO}" && gh issue edit "${ISSUE_NUMBER}" --title "${ISSUE_TITLE}" --body-file "${BODY_FILE}")
  ISSUE_URL="$(cd "${REPO}" && gh issue view "${ISSUE_NUMBER}" --json url --jq .url)"
else
  ISSUE_URL="$(cd "${REPO}" && gh issue create --title "${ISSUE_TITLE}" --body-file "${BODY_FILE}")"
fi
rm -f "${BODY_FILE}"
TRACE="$(traceability_for_artifact "${ARTIFACT}")"
record_git_ref "${SCRIPT_DIR}" "${TRACE}" issue "${ISSUE_URL}"
echo "[agile-github] issue synchronized: ${ISSUE_URL}"
