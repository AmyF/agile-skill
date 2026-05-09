#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="${1:-$(pwd)}"
PROJECT_NAME="${2:-$(basename "${TARGET_DIR}")}"
OWNER="${3:-user}"
PROFILE="${4:-app}"

case "${PROFILE}" in
  app|game) ;;
  *) echo "ERROR: profile must be app or game" >&2; exit 2 ;;
esac

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
TEMPLATE_DIR="${SKILL_DIR}/templates"
AGILE_DIR="${TARGET_DIR}/.agile"
CREATED_AT="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

[ ! -d "${AGILE_DIR}" ] || { echo "ERROR: .agile already exists: ${AGILE_DIR}" >&2; exit 1; }

mkdir -p "${AGILE_DIR}/changes" "${AGILE_DIR}/features" "${AGILE_DIR}/releases"
cp "${TEMPLATE_DIR}/agile.yaml" "${AGILE_DIR}/agile.yaml"
cp "${TEMPLATE_DIR}/status.yaml" "${AGILE_DIR}/status.yaml"
cp "${TEMPLATE_DIR}/feature-index.md" "${AGILE_DIR}/feature-index.md"
cp "${TEMPLATE_DIR}/decision-log.md" "${AGILE_DIR}/decision-log.md"

for file in "${AGILE_DIR}/agile.yaml" "${AGILE_DIR}/status.yaml"; do
  sed -i.bak \
    -e "s/{{schema_version}}/2.0.0/g" \
    -e "s/{{repo_name}}/${PROJECT_NAME}/g" \
    -e "s/{{profile}}/${PROFILE}/g" \
    -e "s/{{repo_provider}}/local/g" \
    -e "s/{{repo_owner}}/${OWNER}/g" \
    -e "s#{{repo_url}}#null#g" \
    -e "s/{{created_at}}/${CREATED_AT}/g" \
    -e "s/{{updated_at}}/${CREATED_AT}/g" \
    -e "s/{{owner}}/${OWNER}/g" \
    "${file}"
  rm -f "${file}.bak"
done

"${SCRIPT_DIR}/validate-placeholders.sh" "${TARGET_DIR}"
"${SCRIPT_DIR}/validate-agile-yaml.sh" "${AGILE_DIR}/agile.yaml"
"${SCRIPT_DIR}/validate-status.sh" "${AGILE_DIR}/status.yaml"
echo "[agile-run] initialized .agile runtime (${PROFILE})"
