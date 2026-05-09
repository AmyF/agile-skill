#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="${1:-}"
FEATURE_ID="${2:-}"
STORY_ID="${3:-}"
STORY_TITLE="${4:-}"
OWNER="${5:-user}"
PROFILE="${6:-}"
RISK="${7:-medium}"

[ -n "${TARGET_DIR}" ] && [ -n "${FEATURE_ID}" ] && [ -n "${STORY_ID}" ] && [ -n "${STORY_TITLE}" ] || {
  echo "Usage: new-story.sh <target-dir> <feature-id> <story-id> <story-title> [owner] [profile] [risk]" >&2
  exit 2
}

FEATURE_DIR="${TARGET_DIR}/.agile/features/${FEATURE_ID}"
if [ -z "${PROFILE}" ] && [ -f "${FEATURE_DIR}/feature.yaml" ]; then
  PROFILE="$(awk -F': ' '/profile:/ {gsub("\"", "", $2); print $2; exit}' "${FEATURE_DIR}/feature.yaml")"
fi
PROFILE="${PROFILE:-app}"
case "${PROFILE}" in app|game) ;; *) echo "ERROR: profile must be app or game" >&2; exit 2 ;; esac
case "${RISK}" in low|medium|high) ;; *) echo "ERROR: risk must be low, medium, or high" >&2; exit 2 ;; esac

if [ "${PROFILE}" = "game" ]; then
  PROFILE_GATE_ID="game_playtest_evidence"
  PROFILE_GATE_NAME="Game playtest or feel evidence linked"
else
  PROFILE_GATE_ID="app_profile_review"
  PROFILE_GATE_NAME="App profile review linked"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)/templates"
STORY_DIR="${FEATURE_DIR}/stories/${STORY_ID}"
CREATED_AT="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
SLUG="$(echo "${STORY_ID}" | sed -E 's/^US-[0-9]{3}-//')"

[ ! -d "${STORY_DIR}" ] || { echo "ERROR: story exists" >&2; exit 1; }

mkdir -p "${STORY_DIR}/fid" "${STORY_DIR}/tdd" "${STORY_DIR}/acceptance" "${STORY_DIR}/evidence"
cp "${TEMPLATE_DIR}/story.yaml" "${STORY_DIR}/story.yaml"
cp "${TEMPLATE_DIR}/evidence.yaml" "${STORY_DIR}/evidence/evidence.yaml"
cp "${TEMPLATE_DIR}/traceability.yaml" "${STORY_DIR}/traceability.yaml"

for file in "${STORY_DIR}/story.yaml" "${STORY_DIR}/evidence/evidence.yaml" "${STORY_DIR}/traceability.yaml"; do
  sed -i.bak \
    -e "s/{{schema_version}}/2.0.0/g" \
    -e "s/{{scope}}/story/g" \
    -e "s/{{feature_id}}/${FEATURE_ID}/g" \
    -e "s/{{story_id}}/${STORY_ID}/g" \
    -e "s/{{story_slug}}/${SLUG}/g" \
    -e "s/{{story_title}}/${STORY_TITLE}/g" \
    -e "s/{{profile}}/${PROFILE}/g" \
    -e "s/{{risk}}/${RISK}/g" \
    -e "s/{{story_owner}}/${OWNER}/g" \
    -e "s/{{owner}}/${OWNER}/g" \
    -e "s/{{profile_specific_gate_id}}/${PROFILE_GATE_ID}/g" \
    -e "s/{{profile_specific_gate_name}}/${PROFILE_GATE_NAME}/g" \
    -e "s/{{created_at}}/${CREATED_AT}/g" \
    -e "s/{{updated_at}}/${CREATED_AT}/g" \
    "${file}"
  rm -f "${file}.bak"
done

if [ "${RISK}" = "high" ]; then
  sed -i.bak \
    -e 's/required: false/required: true/' \
    -e 's/reason: "inherits_feature_policy"/reason: "high_risk_change"/' \
    -e 's/status: "waived"/status: "pending"/' \
    -e 's/No story-specific DDD trigger identified yet./DDD required for high-risk story./' \
    "${STORY_DIR}/story.yaml"
  rm -f "${STORY_DIR}/story.yaml.bak"
fi

"${SCRIPT_DIR}/validate-story.sh" "${STORY_DIR}/story.yaml"
"${SCRIPT_DIR}/validate-evidence.sh" "${STORY_DIR}/evidence/evidence.yaml"
"${SCRIPT_DIR}/validate-traceability.sh" "${STORY_DIR}/traceability.yaml"
"${SCRIPT_DIR}/validate-placeholders.sh" "${TARGET_DIR}"
echo "[agile-run] story created: ${STORY_ID}"
