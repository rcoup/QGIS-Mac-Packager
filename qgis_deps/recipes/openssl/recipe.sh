#!/bin/bash

DESC_openssl="Cryptography and SSL/TLS Toolkit"

# version of your package
# NOTE openssl version must be compatible with QT version, for example
# for Qt 5.14 see https://wiki.qt.io/Qt_5.14.1_Known_Issues
VERSION_openssl=1.1.1d

# dependencies of this recipe
DEPS_openssl=()

LINK_libssl_version=1.1
LINK_libcrypto_version=${LINK_libssl_version}

# url of the package
URL_openssl=https://www.openssl.org/source/openssl-${VERSION_openssl}.tar.gz

# md5 of the package
MD5_openssl=3be209000dbc7e1b95bcdf47980a3baa

# default build path
BUILD_openssl=$BUILD_PATH/openssl/$(get_directory $URL_openssl)

# default recipe path
RECIPE_openssl=$RECIPES_PATH/openssl

patch_openssl_linker_links () {
  install_name_tool -id "@rpath/libssl.dylib" ${STAGE_PATH}/lib/libssl.dylib
  install_name_tool -id "@rpath/libcrypto.dylib" ${STAGE_PATH}/lib/libcrypto.dylib

  # check libs are the same
  if [ ! -f "${STAGE_PATH}/lib/libssl.${LINK_libssl_version}.dylib" ]; then
    error "file ${STAGE_PATH}/lib/libssl.${LINK_libssl_version}.dylib does not exist... maybe you updated the openssl version?"
  fi
  if [ ! -f "${STAGE_PATH}/lib/libcrypto.${LINK_libcrypto_version}.dylib" ]; then
    error "file ${STAGE_PATH}/lib/libcrypto.${LINK_libcrypto_version}.dylib does not exist... maybe you updated the openssl version?"
  fi

  targets=(
    lib/libssl.dylib
    lib/engines-${LINK_libssl_version}/capi.dylib
    lib/engines-${LINK_libssl_version}/padlock.dylib
    bin/openssl
  )

  # Change linked libs
  for i in ${targets[*]}
  do
    install_name_tool -change "${STAGE_PATH}/lib/libssl.${LINK_libssl_version}.dylib" "@rpath/libssl.${LINK_libssl_version}.dylib" ${STAGE_PATH}/$i
    install_name_tool -change "${STAGE_PATH}/lib/libcrypto.${LINK_libcrypto_version}.dylib" "@rpath/libcrypto.${LINK_libcrypto_version}.dylib" ${STAGE_PATH}/$i
    if [[ $i == *"bin/"* ]]; then install_name_tool -add_rpath @executable_path/../lib $STAGE_PATH/$i; fi
  done
}

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_openssl() {
  cd $BUILD_openssl

  # check marker
  if [ -f .patched ]; then
    return
  fi

  patch_configure_file configure

  touch .patched
}

function shouldbuild_openssl() {
  # If lib is newer than the sourcecode skip build
  if [ ${STAGE_PATH}/lib/libssl.dylib -nt $BUILD_openssl/.patched ]; then
    DO_BUILD=0
  fi
}

# function called to build the source code
function build_openssl() {
  try rsync -a $BUILD_openssl/ $BUILD_PATH/openssl/build-$ARCH/
  try cd $BUILD_PATH/openssl/build-$ARCH
  push_env

  # This could interfere with how we expect OpenSSL to build.
  unset OPENSSL_LOCAL_CONFIG_DIR

  # SSLv2 died with 1.1.0, so no-ssl2 no longer required.
  # SSLv3 & zlib are off by default with 1.1.0 but this may not
  # be obvious to everyone, so explicitly state it for now to
  # help debug inevitable breakage.
  try perl ./Configure \
    --prefix=$STAGE_PATH \
    --openssldir=$STAGE_PATH \
    darwin64-x86_64-cc enable-ec_nistp_64_gcc_128 \
    no-ssl3 \
    no-ssl3-method \
    no-zlib \

  check_file_configuration config.status
  try $MAKESMP
  try $MAKESMP install

  patch_openssl_linker_links

  pop_env
}

# function called after all the compile have been done
function postbuild_openssl() {
  verify_lib "libssl.dylib"
  verify_lib "libcrypto.dylib"
  verify_lib "engines-${LINK_libssl_version}/padlock.dylib"
  verify_lib engines-${LINK_libssl_version}/capi.dylib
  verify_bin openssl
  # bin/c_rehash is bash script
}
