#!/usr/bin/env bash
set -euo pipefail
FILE="${1:-}"
if [ -z "${FILE}" ]; then echo "ERROR: Usage: validate-feature.sh <file>" >&2; exit 2; fi
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
python3 "${SCRIPT_DIR}/agile_validate.py" --type feature --file "${FILE}"
