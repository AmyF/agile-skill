#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="${1:-}"
FEATURE_ID="${2:-}"
FEATURE_TITLE="${3:-}"
OWNER="${4:-user}"
PROFILE="${5:-}"
RISK="${6:-medium}"

[ -n "${TARGET_DIR}" ] && [ -n "${FEATURE_ID}" ] && [ -n "${FEATURE_TITLE}" ] || {
  echo "Usage: new-feature.sh <target-dir> <feature-id> <feature-title> [owner] [profile] [risk]" >&2
  exit 2
}

if [ -z "${PROFILE}" ] && [ -f "${TARGET_DIR}/.agile/agile.yaml" ]; then
  PROFILE="$(awk -F': ' '/profile:/ {gsub("\"", "", $2); print $2; exit}' "${TARGET_DIR}/.agile/agile.yaml")"
fi
PROFILE="${PROFILE:-app}"
case "${PROFILE}" in app|game) ;; *) echo "ERROR: profile must be app or game" >&2; exit 2 ;; esac
case "${RISK}" in low|medium|high) ;; *) echo "ERROR: risk must be low, medium, or high" >&2; exit 2 ;; esac

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)/templates"
FEATURE_DIR="${TARGET_DIR}/.agile/features/${FEATURE_ID}"
CREATED_AT="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
SLUG="$(echo "${FEATURE_ID}" | sed -E 's/^FEA-[0-9]{4}-[0-9]{4}-//')"

[ ! -d "${FEATURE_DIR}" ] || { echo "ERROR: feature exists" >&2; exit 1; }

mkdir -p "${FEATURE_DIR}/prd" "${FEATURE_DIR}/ddd" "${FEATURE_DIR}/acceptance" "${FEATURE_DIR}/stories"
cp "${TEMPLATE_DIR}/feature.yaml" "${FEATURE_DIR}/feature.yaml"
cp "${TEMPLATE_DIR}/traceability.yaml" "${FEATURE_DIR}/traceability.yaml"

for file in "${FEATURE_DIR}/feature.yaml" "${FEATURE_DIR}/traceability.yaml"; do
  sed -i.bak \
    -e "s/{{schema_version}}/2.0.0/g" \
    -e "s/{{scope}}/feature/g" \
    -e "s/{{feature_id}}/${FEATURE_ID}/g" \
    -e "s/{{story_id}}/null/g" \
    -e "s/{{feature_slug}}/${SLUG}/g" \
    -e "s/{{feature_title}}/${FEATURE_TITLE}/g" \
    -e "s/{{profile}}/${PROFILE}/g" \
    -e "s/{{risk}}/${RISK}/g" \
    -e "s/{{feature_owner}}/${OWNER}/g" \
    -e "s/{{owner}}/${OWNER}/g" \
    -e "s/{{created_at}}/${CREATED_AT}/g" \
    -e "s/{{updated_at}}/${CREATED_AT}/g" \
    "${file}"
  rm -f "${file}.bak"
done

if [ "${RISK}" = "high" ]; then
  sed -i.bak \
    -e 's/required: false/required: true/' \
    -e 's/reason: "not_classified"/reason: "high_risk_change"/' \
    -e 's/status: "waived"/status: "pending"/' \
    -e 's/No complex domain behavior identified yet./DDD required for high-risk feature./' \
    "${FEATURE_DIR}/feature.yaml"
  rm -f "${FEATURE_DIR}/feature.yaml.bak"
fi

"${SCRIPT_DIR}/validate-feature.sh" "${FEATURE_DIR}/feature.yaml"
"${SCRIPT_DIR}/validate-traceability.sh" "${FEATURE_DIR}/traceability.yaml"
"${SCRIPT_DIR}/validate-placeholders.sh" "${TARGET_DIR}"
echo "[agile-run] feature created: ${FEATURE_ID}"
