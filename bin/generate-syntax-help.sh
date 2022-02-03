#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
[[ "${TRACE:-}" ]] && set -x

readonly VERSION_ARG=${VERSION_ARG:-"--version"}
readonly HELP_ARG=${HELP_ARG:-"--help"}

readonly VERSION_FILE=${VERSION_FILE:-"version.txt"}
readonly HELP_FILE=${HELP_FILE:-"help.txt"}

readonly CHECKSUM_CMD=${CHECKSUM_CMD:-sha256sum}
readonly CHECKSUM_FILE="SHA256SUMS"

readonly OVERRIDE_CNF=".override.cnf"

if [ $# -eq 1 ]; then
  PRODUCT="$1"
else
  # Accept interactive input of product

  echo -n "Enter product name to generate help syntax: "
  read PRODUCT
  [ -z "${PRODUCT}" ] && exit 1
fi

# Validate product command is in path and default checksum utility is also
type ${PRODUCT}  >/dev/null 2>&1 || (echo "ERROR: ${PRODUCT} not found in path" && exit 1)
type ${CHECKSUM_CMD} >/dev/null 2>&1 || (echo "ERROR: ${PRODUCT} not found in path" && exit 1)

[ "$(basename ${PWD})" = "${PRODUCT}" ] && echo "It appears you are already in a directory of this product '${PRODUCT}'" && exit 1
mkdir -p ${PRODUCT}
cd ${PRODUCT}

echo "We are generating content for '${PRODUCT}'"

# If we want to override any variables or add support for extra commands
[ -s "${OVERRIDE_CNF}" ] && source ${OVERRIDE_CNF}

# Generate a version directory. It makes a best guess, which can be renamed later
set +o pipefail # Why head gives 141? - write on a pipe with no reader
VERSION_DIR=$(${PRODUCT} ${VERSION_ARG} | head -1 | tr -dc "0-9.")
set -o pipefail

echo "Creating version directory '${VERSION_DIR}'"
mkdir -p ${VERSION_DIR}
cd ${VERSION_DIR}

# Gather the product version and help information
${PRODUCT} ${VERSION_ARG} > ${VERSION_FILE}
${PRODUCT} ${HELP_ARG} > ${HELP_FILE}

# Process any extra options
if [ -n "${EXTRA_HELP_COMMANDS:-}" ]; then
  echo "Overrides for '${PRODUCT}' exits, running '${EXTRA_HELP_COMMANDS} ${PRODUCT} ${EXTRA_HELP_ARGS}'"
  ${EXTRA_HELP_COMMANDS} ${PRODUCT} ${EXTRA_HELP_ARGS}
fi

# Gather checksum details
# Some filenames may start with --
${CHECKSUM_CMD} -- *.txt > ${CHECKSUM_FILE}
${CHECKSUM_CMD} -c ${CHECKSUM_FILE}

# List details of gathered information
echo
echo "Information for '${PRODUCT}'"
ls -lh -- *.txt
cat ${CHECKSUM_FILE}

echo "We made a best guess the version of '${PRODUCT}' is '${VERSION_DIR}'. If this is not accurate, please rename the directory"

exit 0
