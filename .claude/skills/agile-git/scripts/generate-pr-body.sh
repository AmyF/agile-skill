#!/usr/bin/env bash
set -euo pipefail
cp "$1" "$2"
echo "[agile-git] PR body generated: $2"
