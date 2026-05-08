#!/usr/bin/env bash
set -euo pipefail
TARGET_DIR="${1:-$(pwd)}"
FOUND=0
for f in .github/pull_request_template.md .github/ISSUE_TEMPLATE/agile-feature.yml .github/workflows/agile-gate.yml .github/agile-branch-protection.yaml .github/agile-project-fields.yaml; do [ ! -e "$TARGET_DIR/$f" ] || { echo "EXISTS: $f"; FOUND=1; }; done
[ "$FOUND" -eq 0 ] || exit 1
echo "[agile-github] no overwrite conflicts detected"
