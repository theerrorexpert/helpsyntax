#!/usr/bin/env bash
#
# Use the product help to generate the extra-commands.cnf file
#
set -o errexit
set -o nounset
set -o pipefail

[[ "${TRACE:-}" ]] && set -x
readonly TMP_DIR="${TMP_DIR:-/tmp}"
readonly EXTRA_COMMANDS_FILE="${EXTRA_COMMANDS_FILE:-extra-commands.cnf}"

usage() {
  echo "USAGE: $0 <product> [<command>] (Was given the arguments '$@')"
  exit 1
}



create_extra_commands_file() {
  local PRODUCT="$1"
  local ARGS="$2"

  local TMP_FILE="${TMP_DIR}/${PRODUCT}.tmp.$$"

  # We only collect the first column of output
  ${PRODUCT} ${ARGS} | awk '{print $1}' > ${TMP_FILE}  2>/dev/null || (echo "WARN: '${PRODUCT} ${ARGS}' returned [$?], continuing as this may be valid")
  [ ! -s "${TMP_FILE}" ] && echo "ERROR: '${PRODUCT} ${ARGS}' produced no output" && exit 1

  # Varying project cleanup
  # - Remove Blank Lines
  # - Remove --version
  # - Remove lines starting with Usage
  # - Remove lines starting with Available commands
  # - Remove ==> headers (brew)
  sed -e "/^$/d;/--version/d;/^Usage/d;/^Available/d;/==>/d;" ${TMP_FILE} > ${EXTRA_COMMANDS_FILE}
  rm -f ${TMP_FILE}

  echo "Generated '${EXTRA_COMMANDS_FILE}' with '$(cat ${EXTRA_COMMANDS_FILE} | wc -l | tr -d ' ')' entries"

}

run_extra_commands() {
  local PRODUCT="$1"
  local CMD="generate-extra-syntax-help.sh"
  local LINE

  type ${CMD} >/dev/null 2>&1 || (echo "ERROR: ${CMD} not found in path" && exit 1)

  while read LINE; do
  echo "Running ${LINE}"
    ${CMD} ${PRODUCT} ${LINE}
  done < <(cat ${EXTRA_COMMANDS_FILE})
}


main() {
  [ $# -lt 1 ] && usage "$@"

  PRODUCT="$1"
  shift
  ARGS="$@"
  # Verify product is in path
  type ${PRODUCT} >/dev/null 2>&1 || (echo "ERROR: ${PRODUCT} not found in path" && exit 1)

  if [ -s "../${EXTRA_COMMANDS_FILE}" ]; then
    echo "Using existing crafted commands"
    cp "../${EXTRA_COMMANDS_FILE}" "${EXTRA_COMMANDS_FILE}"
  else
    create_extra_commands_file "${PRODUCT}" "${ARGS}"
  fi

  run_extra_commands "${PRODUCT}"
}


main $@
exit 0
