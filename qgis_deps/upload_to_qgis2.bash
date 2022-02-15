#!/bin/bash

set -e

PWD=`pwd`
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

####################
# load configuration
QGIS_DEPS_RELEASE_VERSION=$1
if [ -z ${QGIS_DEPS_RELEASE_VERSION} ]; then
  error "first argument should be the version of the deps (use ./upload_to_qgis2.bash 0.x)"
  exit 1
fi
CONFIG_FILE="config/deps-${QGIS_DEPS_RELEASE_VERSION}.conf"
if [[ ! -f "${CONFIG_FILE}" ]]; then
  error "invalid config file ${CONFIG_FILE}"
fi
shift
source ${CONFIG_FILE}

INSTALL_SCRIPT=${ROOT_OUT_PATH}/install_qgis_deps-${QGIS_DEPS_SDK_VERSION}.bash

if [ ! -f ${QT_PACKAGE_PATH} ] || [ ! -f ${QGIS_DEPS_PACKAGE_PATH} ] || [ ! -f ${INSTALL_SCRIPT} ] ; then
  echo "Missing archives to upload, maybe you forgot to run ./create_package.bash?"
  echo "QT archive ${QT_PACKAGE_PATH}"
  echo "QGIS deps archive ${QGIS_DEPS_PACKAGE_PATH}"
  echo "Install script ${INSTALL_SCRIPT}"
  exit 1
fi

KEY="${DIR}/../../ssh/id_rsa"
SERVER="qgis-mac-packager-bot@qgis2.qgis.org"
FOLDER="/var/www/downloads/macos"
ROOT="${FOLDER}/deps"

process_file () {
    LOCAL=${1}
    FILENAME=$(basename -- "${LOCAL}")
    REMOTE=${ROOT}/${FILENAME}
    # scp -o LogLevel=Error -i ${KEY} ${LOCAL} ${SERVER}:${REMOTE}
    rsync -v -e "ssh -i ${KEY}" ${LOCAL} ${SERVER}:${REMOTE} --progress
}

echo "Upload QGIS DEPS to qgis2.qgis.org"
ssh -o LogLevel=Error -i ${KEY} ${SERVER} "mkdir -p ${ROOT}"

# upload files
process_file ${QT_PACKAGE_PATH}
process_file ${QGIS_DEPS_PACKAGE_PATH}
process_file ${INSTALL_SCRIPT}
