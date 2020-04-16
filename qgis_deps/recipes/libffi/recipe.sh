#!/bin/bash

DESC_libffi="Portable Foreign Function Interface library"

# version of your package
VERSION_libffi=3.2.1
LINK_libffi=libffi.6.dylib

# dependencies of this recipe
DEPS_libffi=()

# url of the package
URL_libffi=https://sourceware.org/pub/libffi/libffi-${VERSION_libffi}.tar.gz

# md5 of the package
MD5_libffi=83b89587607e3eb65c70d361f13bab43

# default build path
BUILD_libffi=$BUILD_PATH/libffi/$(get_directory $URL_libffi)

# default recipe path
RECIPE_libffi=$RECIPES_PATH/libffi

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_libffi() {
  cd $BUILD_libffi

  # check marker
  if [ -f .patched ]; then
    return
  fi

  patch_configure_file configure

  touch .patched
}

function shouldbuild_libffi() {
  # If lib is newer than the sourcecode skip build
  if [ ${STAGE_PATH}/lib/$LINK_libffi -nt $BUILD_libffi/.patched ]; then
    DO_BUILD=0
  fi
}

# function called to build the source code
function build_libffi() {
  try rsync -a $BUILD_libffi/ $BUILD_PATH/libffi/build-$ARCH/
  try cd $BUILD_PATH/libffi/build-$ARCH
  push_env


  try ${CONFIGURE} \
    --disable-debug \
    --enable-static=no

  check_file_configuration config.status
  try $MAKESMP
  try $MAKE install

  mkdir -p $STAGE_PATH/include
  cp $STAGE_PATH/lib/libffi-${VERSION_libffi}/include/* $STAGE_PATH/include/
  rm -rf $STAGE_PATH/lib/libffi-${VERSION_libffi}

  pop_env
}

# function called after all the compile have been done
function postbuild_libffi() {
  verify_binary lib/$LINK_libffi
}

# function to append information to config file
function add_config_info_libffi() {
  append_to_config_file "# libffi-${VERSION_libffi}: ${DESC_libffi}"
  append_to_config_file "export VERSION_libffi=${VERSION_libffi}"
  append_to_config_file "export LINK_libffi=${LINK_libffi}"
}