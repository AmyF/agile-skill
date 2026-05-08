#!/usr/bin/env bash
set -euo pipefail
TARGET_DIR="${1:-}"; FEATURE_ID="${2:-}"; FEATURE_TITLE="${3:-}"; OWNER="${4:-user}"
[ -n "$TARGET_DIR" ] && [ -n "$FEATURE_ID" ] && [ -n "$FEATURE_TITLE" ] || { echo "Usage: new-feature.sh <target-dir> <feature-id> <feature-title> [owner]" >&2; exit 2; }
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; TEMPLATE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)/templates"; FEATURE_DIR="${TARGET_DIR}/.agile/features/${FEATURE_ID}"; CREATED_AT="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"; SLUG="$(echo "$FEATURE_ID"|sed -E 's/^FEA-[0-9]{4}-[0-9]{4}-//')"
[ ! -d "$FEATURE_DIR" ] || { echo "ERROR: feature exists" >&2; exit 1; }
mkdir -p "$FEATURE_DIR/prd" "$FEATURE_DIR/ddd" "$FEATURE_DIR/stories"; cp "$TEMPLATE_DIR/feature.yaml" "$FEATURE_DIR/feature.yaml"; cp "$TEMPLATE_DIR/traceability.yaml" "$FEATURE_DIR/traceability.yaml"
for f in "$FEATURE_DIR/feature.yaml" "$FEATURE_DIR/traceability.yaml"; do sed -i.bak -e "s/{{schema_version}}/1.0.0/g" -e "s/{{feature_id}}/${FEATURE_ID}/g" -e "s/{{feature_slug}}/${SLUG}/g" -e "s/{{feature_title}}/${FEATURE_TITLE}/g" -e "s/{{feature_owner}}/${OWNER}/g" -e "s/{{owner}}/${OWNER}/g" -e "s/{{created_at}}/${CREATED_AT}/g" -e "s/{{updated_at}}/${CREATED_AT}/g" "$f"; rm -f "$f.bak"; done
"$SCRIPT_DIR/validate-feature.sh" "$FEATURE_DIR/feature.yaml"; "$SCRIPT_DIR/validate-traceability.sh" "$FEATURE_DIR/traceability.yaml"; "$SCRIPT_DIR/validate-placeholders.sh" "$TARGET_DIR"
echo "[agile-run] feature created: $FEATURE_ID"
