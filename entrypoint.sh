#!/bin/sh
set -o errexit

REPORT_FILE=$(mktemp)

/usr/local/bin/parallel-lint \
  --json \
  -e php,html \
  "${@}" > "${REPORT_FILE}" || PARALLEL_LINT_STATUS=${?}

test -f "${REPORT_FILE}" && (jq --raw-output '.results.errors[] | "::error " + "file=" + .file + ",line=" + (.line|tostring) + "::" + .normalizeMessage' "${REPORT_FILE}" || cat "${REPORT_FILE}")

exit ${PARALLEL_LINT_STATUS}
