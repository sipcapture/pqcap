#!/usr/bin/env bash
# Regression guard for code scanning rule actions/missing-workflow-permissions.
#
# Every workflow must declare an explicit top-level `permissions:` block so the
# GITHUB_TOKEN scope is not silently inherited from repository/organization
# defaults (which may be read-write). This is what CI code scanning alert #1
# flagged for .github/workflows/ci.yml.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
WORKFLOW_DIR="${ROOT_DIR}/.github/workflows"

status=0
shopt -s nullglob
workflows=("${WORKFLOW_DIR}"/*.yml "${WORKFLOW_DIR}"/*.yaml)
shopt -u nullglob

if [ "${#workflows[@]}" -eq 0 ]; then
  echo "FAIL: no workflow files found under ${WORKFLOW_DIR}" >&2
  exit 1
fi

for wf in "${workflows[@]}"; do
  name="$(basename "${wf}")"
  if ! grep -Eq '^permissions:' "${wf}"; then
    echo "FAIL: ${name} has no top-level permissions block" >&2
    status=1
    continue
  fi
  echo "ok: ${name} declares top-level permissions"
done

exit "${status}"