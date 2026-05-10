#!/usr/bin/env bash
set -euo pipefail
FILE="${1:-$(pwd)/.agile/agile.yaml}"
PATTERN="api.github.com|Authorization:[[:space:]]*token|GITHUB_TOKEN|gh[[:space:]]+api"
if grep -Eq "$PATTERN" "$FILE"; then echo "ERROR: direct GitHub API/token automation detected" >&2; exit 1; fi
echo "[agile-github] GitHub config validation passed"
