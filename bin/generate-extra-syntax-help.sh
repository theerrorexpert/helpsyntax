#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
[[ "${TRACE:-}" ]] && set -x
readonly TMP_DIR="${TMP_DIR:-/tmp}"
readonly HELP_ARG=${HELP_ARG:-"--help"}

usage() {
  echo "USAGE: $0 <product> <command> [..<args>] (Was given the arguments '$@')"
  echo ""
  echo "You can override the default HELP_ARG"
  exit 1
}



[ $# -lt 2 ] && usage "$@"
PRODUCT="$1"
shift
ARGS="$@"


# Verify product is in path
type ${PRODUCT} >/dev/null 2>&1 || (echo "ERROR: ${PRODUCT} not found in path" && exit 1)

# This process assumes you have navigated to the appropiate product+version for output
TMP_FILE="${TMP_DIR}/${PRODUCT}.tmp.$$"
${PRODUCT} ${ARGS} ${HELP_ARG} > ${TMP_FILE}  2>/dev/null || (echo "ERROR: '${PRODUCT} ${ARGS}' is an invalid command, skipping" && exit 0)
[ ! -s "${TMP_FILE}" ] && echo "ERROR: '${PRODUCT} ${ARGS}' produced no output" && exit 1

FORMATTED_FILE=$(tr -d ' ' <<< ${ARGS}).txt
echo "Creating '${FORMATTED_FILE}'"
mv ${TMP_FILE} ${FORMATTED_FILE}

rm -f ${TMP_FILE}

exit 0
