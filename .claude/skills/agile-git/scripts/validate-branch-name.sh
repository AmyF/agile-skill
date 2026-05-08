#!/usr/bin/env bash
set -euo pipefail
BRANCH="${1:-}"
[[ "$BRANCH" =~ ^(doc|impl|test|acceptance|release|hotfix|recovery|chore)/.+/.+ ]] || { echo "ERROR: invalid branch name" >&2; exit 1; }
echo "[agile-git] branch name valid"
