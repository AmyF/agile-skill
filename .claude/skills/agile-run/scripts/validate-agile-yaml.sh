#!/usr/bin/env bash
set -euo pipefail
FILE="${1:-$(pwd)/.agile/agile.yaml}"
if [ -z "${FILE}" ]; then echo "ERROR: Usage: validate-agile-yaml.sh <file>" >&2; exit 2; fi
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
python3 "${SCRIPT_DIR}/agile_validate.py" --type agile --file "${FILE}"
