#!/bin/bash

DESC_bison="Parser generator"


DEPS_bison=(gettext)

# default build path
BUILD_bison=${DEPS_BUILD_PATH}/bison/$(get_directory $URL_bison)

# default recipe path
RECIPE_bison=$RECIPES_PATH/bison

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_bison() {
  cd $BUILD_bison
    patch_configure_file configure
  try rsync  -a $BUILD_bison/ ${DEPS_BUILD_PATH}/bison/build-${ARCH}

}


# function called after all the compile have been done
function postbuild_bison() {
  verify_binary bin/bison
}

# function to append information to config file
function add_config_info_bison() {
  append_to_config_file "# bison-${VERSION_bison}: ${DESC_bison}"
  append_to_config_file "export VERSION_bison=${VERSION_bison}"
}