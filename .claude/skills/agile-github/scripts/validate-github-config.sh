#!/usr/bin/env bash
set -euo pipefail
FILE="${1:-$(pwd)/.agile/agile.yaml}"
PATTERN="auto_""create|auto_""update|auto_""close|auto_""add_items|sync_""fields|last_""synced_at"
if grep -Eq "$PATTERN" "$FILE"; then echo "ERROR: disallowed GitHub automation config detected" >&2; exit 1; fi
echo "[agile-github] GitHub config validation passed"
