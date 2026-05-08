#!/usr/bin/env bash
set -euo pipefail
TARGET_DIR="${1:-$(pwd)}"; AGILE_DIR="${TARGET_DIR}/.agile"
[ -d "${AGILE_DIR}" ] || { echo "ERROR: .agile directory not found: ${AGILE_DIR}" >&2; exit 2; }
MATCHES="$(grep -RIn '{{[^}]*}}' "${AGILE_DIR}" 2>/dev/null || true)"
if [ -n "${MATCHES}" ]; then echo "Unresolved placeholders found:"; echo "${MATCHES}"; exit 1; fi
echo "[agile-run] placeholder validation passed"
