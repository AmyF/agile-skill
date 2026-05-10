#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: commit-agile.sh <repo> <commit-type> <agile-id> <summary> --all|--paths <path>... [--traceability <file>] [--dry-run]" >&2
}

REPO="${1:-}"
COMMIT_TYPE="${2:-}"
AGILE_ID="${3:-}"
SUMMARY="${4:-}"
shift 4 2>/dev/null || { usage; exit 2; }

MODE=""
TRACEABILITY=""
DRY_RUN=false
PATHS=()

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=true; shift ;;
    --traceability) TRACEABILITY="${2:-}"; shift 2 ;;
    --all) MODE="all"; shift ;;
    --paths) MODE="paths"; shift ;;
    *)
      if [ "${MODE}" = "paths" ]; then
        PATHS+=("$1")
        shift
      else
        usage
        exit 2
      fi
      ;;
  esac
done

[ -n "${REPO}" ] && [ -n "${COMMIT_TYPE}" ] && [ -n "${AGILE_ID}" ] && [ -n "${SUMMARY}" ] || { usage; exit 2; }
[ -d "${REPO}/.git" ] || { echo "ERROR: not a git repository: ${REPO}" >&2; exit 2; }
[ "${MODE}" = "all" ] || [ "${MODE}" = "paths" ] || { usage; exit 2; }
[ "${MODE}" != "paths" ] || [ "${#PATHS[@]}" -gt 0 ] || { usage; exit 2; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MESSAGE="${COMMIT_TYPE}(${AGILE_ID}): ${SUMMARY}"
MSG_FILE="$(mktemp)"
printf '%s\n' "${MESSAGE}" > "${MSG_FILE}"
"${SCRIPT_DIR}/validate-commit-message.sh" "${MSG_FILE}" >/dev/null
rm -f "${MSG_FILE}"

if [ "${DRY_RUN}" = true ]; then
  if [ "${MODE}" = "all" ]; then
    echo "git -C ${REPO} add -A"
  else
    printf 'git -C %s add' "${REPO}"
    printf ' %q' "${PATHS[@]}"
    printf '\n'
  fi
  printf 'git -C %q commit -m %q\n' "${REPO}" "${MESSAGE}"
  [ -z "${TRACEABILITY}" ] || echo "record commit <new-commit-sha> in ${TRACEABILITY}"
  exit 0
fi

if [ "${MODE}" = "all" ]; then
  git -C "${REPO}" add -A
else
  git -C "${REPO}" add "${PATHS[@]}"
fi

if git -C "${REPO}" diff --cached --quiet; then
  echo "ERROR: no staged changes to commit" >&2
  exit 1
fi

git -C "${REPO}" commit -m "${MESSAGE}"
COMMIT_SHA="$(git -C "${REPO}" rev-parse HEAD)"
[ -z "${TRACEABILITY}" ] || "${SCRIPT_DIR}/record-git-ref.py" "${TRACEABILITY}" commit "${COMMIT_SHA}"
echo "[agile-git] committed: ${MESSAGE}"
