#!/usr/bin/env bash
#
# Customized for awscli
# Use the product help to generate the extra-commands.cnf file
#
set -o errexit
set -o nounset
set -o pipefail

[[ "${TRACE:-}" ]] && set -x
readonly TMP_DIR="${TMP_DIR:-/tmp}"
EXTRA_COMMANDS_FILE="${EXTRA_COMMANDS_FILE:-extra-commands.cnf}"

usage() {
  echo "USAGE: $0 <product> [<command>] (Was given the arguments '$@')"
  exit 1
}



create_extra_commands_file() {
  local PRODUCT="$1"
  shift
  local ARGS="$*"
  local EXTRA

  [ $# -gt 1 ] && EXTRA="$1" || EXTRA=${EXTRA:-}

  local TMP_FILE="${TMP_DIR}/${PRODUCT}.tmp.$$"

  # We only collect the first column of output
  ${PRODUCT} ${ARGS} help > ${TMP_FILE} 2>&1 || :
  [ ! -s "${TMP_FILE}" ] && echo "ERROR: '${PRODUCT} ${ARGS}' produced no output" && exit 1

  sed -e "1,/Invalid choice/d" ${TMP_FILE} | tr -d ' ' | sed -e "/^$/d" |   awk -F'|' '{printf("%s\n%s\n",$1,$2)}' | sed -e "/^$/d" | sed -e "s/^/${EXTRA} /" | sort >> ${EXTRA_COMMANDS_FILE}
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
    HELP_ARG=help ${CMD} ${PRODUCT} ${LINE}
  done < <(cat ${EXTRA_COMMANDS_FILE})
}


main() {
  PRODUCT="aws"

  # Verify product is in path
  type ${PRODUCT} >/dev/null 2>&1 || (echo "ERROR: ${PRODUCT} not found in path" && exit 1)

  > ${EXTRA_COMMANDS_FILE}
  create_extra_commands_file "${PRODUCT}" "xxx"

  #cp ${EXTRA_COMMANDS_FILE} ${EXTRA_COMMANDS_FILE}.primary
  PRIMARY_EXTRA_COMMANDS_FILE=${EXTRA_COMMANDS_FILE}
  run_extra_commands "${PRODUCT}"

  while read LINE; do
    echo "Running '${LINE}' options"
    EXTRA_COMMANDS_FILE="${LINE}.cnf"
    create_extra_commands_file "${PRODUCT}" "${LINE}" "xxx"
    run_extra_commands "${PRODUCT}"
  done < <(cat ${PRIMARY_EXTRA_COMMANDS_FILE})

}

main
exit 0
