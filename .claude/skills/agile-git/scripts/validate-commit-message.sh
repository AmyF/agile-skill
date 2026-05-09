#!/usr/bin/env bash
set -euo pipefail

FILE="${1:-}"
[ -n "${FILE}" ] || { echo "Usage: validate-commit-message.sh <commit-message-file>" >&2; exit 2; }

ID_PATTERN='(FEA-[0-9]{4}-[0-9]{4}-[a-z0-9][a-z0-9-]*|US-[0-9]{3}-[a-z0-9][a-z0-9-]*|CR-[0-9]{4}-[0-9]{4}-[a-z0-9][a-z0-9-]*|REL-[0-9]{4}-[0-9]{4})'
head -n1 "${FILE}" | grep -Eq "^(docs|feat|fix|test|refactor|chore|release|hotfix|recovery)\\(${ID_PATTERN}\\): .+" || {
  echo "ERROR: invalid commit message" >&2
  exit 1
}

echo "[agile-git] commit message valid"
