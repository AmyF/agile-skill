#!/usr/bin/env bash
set -euo pipefail
TARGET_DIR="${1:-$(pwd)}"; PROJECT_NAME="${2:-$(basename "${TARGET_DIR}")}"; OWNER="${3:-user}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; SKILL_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"; TEMPLATE_DIR="${SKILL_DIR}/templates"; AGILE_DIR="${TARGET_DIR}/.agile"
[ ! -d "${AGILE_DIR}" ] || { echo "ERROR: .agile already exists: ${AGILE_DIR}" >&2; exit 1; }
CREATED_AT="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
mkdir -p "${AGILE_DIR}/changes" "${AGILE_DIR}/features" "${AGILE_DIR}/releases"
cp "${TEMPLATE_DIR}/agile.yaml" "${AGILE_DIR}/agile.yaml"; cp "${TEMPLATE_DIR}/status.yaml" "${AGILE_DIR}/status.yaml"; cp "${TEMPLATE_DIR}/feature-index.md" "${AGILE_DIR}/feature-index.md"; cp "${TEMPLATE_DIR}/decision-log.md" "${AGILE_DIR}/decision-log.md"; cp "${TEMPLATE_DIR}/recovery-log.md" "${AGILE_DIR}/recovery-log.md"
for f in "${AGILE_DIR}/agile.yaml" "${AGILE_DIR}/status.yaml"; do sed -i.bak -e "s/{{schema_version}}/1.0.0/g" -e "s/{{repo_name}}/${PROJECT_NAME}/g" -e "s/{{repo_provider}}/local/g" -e "s/{{repo_owner}}/${OWNER}/g" -e "s#{{repo_url}}#null#g" -e "s/{{created_at}}/${CREATED_AT}/g" -e "s/{{updated_at}}/${CREATED_AT}/g" -e "s/{{owner}}/${OWNER}/g" "$f"; rm -f "$f.bak"; done
"${SCRIPT_DIR}/validate-placeholders.sh" "${TARGET_DIR}"; "${SCRIPT_DIR}/validate-agile-yaml.sh" "${AGILE_DIR}/agile.yaml"; "${SCRIPT_DIR}/validate-status.sh" "${AGILE_DIR}/status.yaml"
echo "[agile-run] initialized .agile runtime"
