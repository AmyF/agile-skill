#!/usr/bin/env bash
set -euo pipefail
TARGET_DIR="${1:-}"; FEATURE_ID="${2:-}"; STORY_ID="${3:-}"; STORY_TITLE="${4:-}"; OWNER="${5:-user}"
[ -n "$TARGET_DIR" ] && [ -n "$FEATURE_ID" ] && [ -n "$STORY_ID" ] && [ -n "$STORY_TITLE" ] || { echo "Usage: new-story.sh <target-dir> <feature-id> <story-id> <story-title> [owner]" >&2; exit 2; }
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; TEMPLATE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)/templates"; STORY_DIR="${TARGET_DIR}/.agile/features/${FEATURE_ID}/stories/${STORY_ID}"; CREATED_AT="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"; SLUG="$(echo "$STORY_ID"|sed -E 's/^US-[0-9]{3}-//')"
mkdir -p "$STORY_DIR/fid" "$STORY_DIR/tdd" "$STORY_DIR/acceptance" "$STORY_DIR/evidence"; cp "$TEMPLATE_DIR/story.yaml" "$STORY_DIR/story.yaml"; cp "$TEMPLATE_DIR/evidence.yaml" "$STORY_DIR/evidence/evidence.yaml"
for f in "$STORY_DIR/story.yaml" "$STORY_DIR/evidence/evidence.yaml"; do sed -i.bak -e "s/{{schema_version}}/1.0.0/g" -e "s/{{feature_id}}/${FEATURE_ID}/g" -e "s/{{story_id}}/${STORY_ID}/g" -e "s/{{story_slug}}/${SLUG}/g" -e "s/{{story_title}}/${STORY_TITLE}/g" -e "s/{{story_owner}}/${OWNER}/g" -e "s/{{owner}}/${OWNER}/g" -e "s/{{created_at}}/${CREATED_AT}/g" -e "s/{{updated_at}}/${CREATED_AT}/g" "$f"; rm -f "$f.bak"; done
"$SCRIPT_DIR/validate-story.sh" "$STORY_DIR/story.yaml"; "$SCRIPT_DIR/validate-evidence.sh" "$STORY_DIR/evidence/evidence.yaml"; "$SCRIPT_DIR/validate-placeholders.sh" "$TARGET_DIR"
echo "[agile-run] story created: $STORY_ID"
