#!/usr/bin/env bash
set -euo pipefail
echo "$1/$2/$(echo "$3"|tr "[:upper:]" "[:lower:]"|sed -E "s/[^a-z0-9]+/-/g; s/^-+//; s/-+$//")"
