#!/usr/bin/env bash
set -euo pipefail
FILE="${1:-}"
head -n1 "$FILE" | grep -Eq "^(docs|feat|fix|test|refactor|chore|release|hotfix|recovery)\(.+\): .+" || { echo "ERROR: invalid commit message" >&2; exit 1; }
echo "[agile-git] commit message valid"
