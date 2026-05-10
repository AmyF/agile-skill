#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: create-pr.sh <repo> <story-or-feature-artifact> [--base <base>] [--dry-run]" >&2
}

REPO="${1:-}"
ARTIFACT="${2:-}"
shift 2 2>/dev/null || { usage; exit 2; }
BASE="main"
DRY_RUN=false

while [ "$#" -gt 0 ]; do
  case "$1" in
    --base) BASE="${2:-}"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    *) usage; exit 2 ;;
  esac
done

[ -n "${REPO}" ] && [ -n "${ARTIFACT}" ] || { usage; exit 2; }
[ -f "${ARTIFACT}" ] || { echo "ERROR: artifact not found: ${ARTIFACT}" >&2; exit 2; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
. "${SCRIPT_DIR}/github-common.sh"
SKILLS="$(skills_dir "${SCRIPT_DIR}")"

require_controlled_mode "${REPO}"
run_agile_gates "${REPO}" "${SCRIPT_DIR}" >/dev/null
BRANCH="$(git -C "${REPO}" branch --show-current)"
[ -n "${BRANCH}" ] || { echo "ERROR: detached HEAD cannot create PR" >&2; exit 1; }
"${SKILLS}/agile-git/scripts/validate-branch-name.sh" "${BRANCH}" >/dev/null
if [ "${DRY_RUN}" != true ] && [ -n "$(git -C "${REPO}" status --porcelain)" ]; then
  echo "ERROR: dirty worktree; commit or stash changes before creating PR" >&2
  exit 1
fi

ID="$(artifact_id "${ARTIFACT}")"
TITLE="$(artifact_title "${ARTIFACT}")"
[ -n "${ID}" ] || ID="$(basename "${ARTIFACT}")"
[ -n "${TITLE}" ] || TITLE="${ID}"
PR_TITLE="[${ID}] ${TITLE}"
TRACE="$(traceability_for_artifact "${ARTIFACT}")"
BODY_FILE="$(mktemp)"
cat > "${BODY_FILE}" <<EOF
## Agile Metadata

- Agile ID: ${ID}
- Source of truth: .agile
- Artifact: ${ARTIFACT}
- Traceability: ${TRACE:-not found}
- Gate status: passed

Created by agile-run controlled GitHub automation.
EOF

if [ "${DRY_RUN}" = true ]; then
  printf 'cd %q && gh pr create --base %q --head %q --title %q --body-file %q\n' "${REPO}" "${BASE}" "${BRANCH}" "${PR_TITLE}" "${BODY_FILE}"
  cat "${BODY_FILE}"
  rm -f "${BODY_FILE}"
  exit 0
fi

require_gh_auth "${REPO}"
PR_URL="$(cd "${REPO}" && gh pr create --base "${BASE}" --head "${BRANCH}" --title "${PR_TITLE}" --body-file "${BODY_FILE}")"
rm -f "${BODY_FILE}"
record_git_ref "${SCRIPT_DIR}" "${TRACE}" pull_request "${PR_URL}"
echo "[agile-github] PR created: ${PR_URL}"
