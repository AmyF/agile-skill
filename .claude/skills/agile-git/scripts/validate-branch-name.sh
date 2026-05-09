#!/usr/bin/env bash
set -euo pipefail

BRANCH="${1:-}"
ID_PATTERN='(FEA-[0-9]{4}-[0-9]{4}-[a-z0-9][a-z0-9-]*|US-[0-9]{3}-[a-z0-9][a-z0-9-]*|CR-[0-9]{4}-[0-9]{4}-[a-z0-9][a-z0-9-]*|REL-[0-9]{4}-[0-9]{4})'

[[ "${BRANCH}" =~ ^(doc|impl|test|acceptance|release|hotfix|recovery|chore)/${ID_PATTERN}/[a-z0-9][a-z0-9-]*$ ]] || {
  echo "ERROR: invalid branch name" >&2
  exit 1
}

echo "[agile-git] branch name valid"
