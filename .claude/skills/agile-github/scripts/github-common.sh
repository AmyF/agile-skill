#!/usr/bin/env bash

github_mode() {
  local repo="$1"
  local file="${repo}/.agile/agile.yaml"
  [ -f "${file}" ] || { echo "ERROR: missing ${file}" >&2; return 2; }
  awk '
    /^[[:space:]]*github:/ { in_github=1; next }
    in_github && /^[[:space:]]+[a-zA-Z_]+:/ {
      key=$1; gsub(":", "", key)
      if (key == "mode") {
        value=$2; gsub("\"", "", value); print value; exit
      }
    }
    in_github && /^[^[:space:]]/ { in_github=0 }
  ' "${file}"
}

require_controlled_mode() {
  local repo="$1"
  local mode
  mode="$(github_mode "${repo}")"
  [ "${mode}" = "gh_controlled" ] || {
    echo "ERROR: GitHub remote mutation requires integrations.github.mode: gh_controlled" >&2
    exit 1
  }
}

require_gh_auth() {
  local repo="$1"
  command -v gh >/dev/null 2>&1 || { echo "ERROR: GitHub CLI gh is not installed" >&2; exit 1; }
  (cd "${repo}" && gh auth status >/dev/null)
}

skills_dir() {
  local script_dir="$1"
  cd "${script_dir}/../.." && pwd
}

run_agile_gates() {
  local repo="$1"
  local script_dir="$2"
  local skills
  skills="$(skills_dir "${script_dir}")"
  "${skills}/agile-run/scripts/validate-gates.sh" "${repo}"
}

artifact_title() {
  local artifact="$1"
  awk -F': ' '/title:/ {gsub("\"", "", $2); print $2; exit}' "${artifact}"
}

artifact_id() {
  local artifact="$1"
  awk -F': ' '/^[[:space:]]+id:/ {gsub("\"", "", $2); print $2; exit}' "${artifact}"
}

traceability_for_artifact() {
  local artifact="$1"
  local dir
  dir="$(dirname "${artifact}")"
  [ -f "${dir}/traceability.yaml" ] && printf '%s\n' "${dir}/traceability.yaml"
}

traceability_for_pr() {
  local repo="$1"
  local pr_number="$2"
  [ -d "${repo}/.agile" ] || return 0
  find "${repo}/.agile" -name traceability.yaml -type f -exec grep -lE "(pull/${pr_number}|#${pr_number}|pr-${pr_number}|PR-${pr_number}|dry-run-pr-${pr_number})" {} + 2>/dev/null | head -n 1
}

has_merge_approval() {
  local repo="$1"
  grep -RInE 'type:[[:space:]]*"?((merge|release)_approval)"?' "${repo}/.agile" >/dev/null 2>&1
}

record_git_ref() {
  local script_dir="$1"
  local trace="$2"
  local ref_type="$3"
  local value="$4"
  local skills
  [ -n "${trace}" ] && [ -f "${trace}" ] || return 0
  skills="$(skills_dir "${script_dir}")"
  "${skills}/agile-git/scripts/record-git-ref.py" "${trace}" "${ref_type}" "${value}"
}
