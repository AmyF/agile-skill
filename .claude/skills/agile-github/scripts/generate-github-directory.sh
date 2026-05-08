#!/usr/bin/env bash
set -euo pipefail
TARGET_DIR="${1:-$(pwd)}"; MODE="${2:-issue-pr}"; SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; T="$(cd "$SCRIPT_DIR/.." && pwd)/templates"
mkdir -p "$TARGET_DIR/.github"
copy(){ [ ! -e "$2" ] || { echo "SKIP existing file: $2"; return; }; mkdir -p "$(dirname "$2")"; cp "$1" "$2"; echo "WROTE: $2"; }
case "$MODE" in pr-only) copy "$T/github/pull_request_template.md" "$TARGET_DIR/.github/pull_request_template.md";; issues-only) for f in agile-feature.yml agile-story.yml agile-change-request.yml agile-release.yml; do copy "$T/github/ISSUE_TEMPLATE/$f" "$TARGET_DIR/.github/ISSUE_TEMPLATE/$f"; done;; issue-pr) "$0" "$TARGET_DIR" pr-only; "$0" "$TARGET_DIR" issues-only;; issue-pr-actions) "$0" "$TARGET_DIR" issue-pr; copy "$T/github/workflows/agile-gate.yml" "$TARGET_DIR/.github/workflows/agile-gate.yml";; issue-pr-actions-project) "$0" "$TARGET_DIR" issue-pr-actions; copy "$T/branch-protection.yaml" "$TARGET_DIR/.github/agile-branch-protection.yaml"; copy "$T/github-project-fields.yaml" "$TARGET_DIR/.github/agile-project-fields.yaml";; *) echo "ERROR: unknown mode" >&2; exit 2;; esac
