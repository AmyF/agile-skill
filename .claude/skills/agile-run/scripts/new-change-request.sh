#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="${1:-}"
CR_ID="${2:-}"
SUMMARY="${3:-}"
OWNER="${4:-user}"

[ -n "${TARGET_DIR}" ] && [ -n "${CR_ID}" ] && [ -n "${SUMMARY}" ] || {
  echo "Usage: new-change-request.sh <target-dir> <cr-id> <summary> [owner]" >&2
  exit 2
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)/templates"
DIR="${TARGET_DIR}/.agile/changes"
CREATED_AT="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
mkdir -p "${DIR}"

cat > "${DIR}/${CR_ID}.record.yaml" <<EOF
schema_version: "2.0.0"
metadata:
  change_request_id: "${CR_ID}"
  status: "proposed"
  created_at: "${CREATED_AT}"
  owner: "${OWNER}"
  affected_feature: null
  affected_story: null
  affected_release: null
interruption_context:
  current_stage: null
  current_state: null
  work_interrupted: null
  approved_artifacts_affected: false
  draft_artifacts_affected: false
  downstream_work_affected: false
  resume_point: null
change_summary: "${SUMMARY}"
reason: "TBD"
change_classification: "draft_semantic_change"
impacted_stages: []
impact_analysis: []
earliest_impacted_stage: "prd"
downstream_revalidation: []
decision: "proposed"
approvals: []
EOF

"${SCRIPT_DIR}/validate-change-request.sh" "${DIR}/${CR_ID}.record.yaml"
cp "${TEMPLATE_DIR}/change-request.md" "${DIR}/${CR_ID}.md"
sed -i.bak \
  -e "s/{{change_request_id}}/${CR_ID}/g" \
  -e "s/{{change_summary}}/${SUMMARY}/g" \
  -e "s/{{created_at}}/${CREATED_AT}/g" \
  -e "s/{{owner}}/${OWNER}/g" \
  -e 's/{{[^}]*}}/TBD/g' \
  "${DIR}/${CR_ID}.md"
rm -f "${DIR}/${CR_ID}.md.bak"
"${SCRIPT_DIR}/validate-placeholders.sh" "${TARGET_DIR}"
echo "[agile-run] change request created: ${CR_ID}"
