#!/bin/bash

DESC_python_pyqt5="PyQt5 package for python"

# version of your package
VERSION_python_pyqt5=5.14.1

# dependencies of this recipe
DEPS_python_pyqt5=(python python_sip qtwebkit)

# url of the package
URL_python_pyqt5=https://files.pythonhosted.org/packages/3a/fb/eb51731f2dc7c22d8e1a63ba88fb702727b324c6352183a32f27f73b8116/PyQt5-${VERSION_python_pyqt5}.tar.gz

# md5 of the package
MD5_python_pyqt5=404ea30ccc1e0ae1c5c0c4318c9a952b

# default build path
BUILD_python_pyqt5=$BUILD_PATH/python_pyqt5/$(get_directory $URL_python_pyqt5)

# default recipe path
RECIPE_python_pyqt5=$RECIPES_PATH/python_pyqt5

function fix_python_pyqt5_paths() {

  # these are sh scripts that calls plain python{VERSION_major_python}
  # so when on path there is homebrew python or other
  # it fails
  targets=(
    bin/pylupdate5
    bin/pyrcc5
    bin/pyuic5
  )

  for i in ${targets[*]}
  do
    try ${SED} 's;exec python${VERSION_major_python};exec `dirname $0`/python${VERSION_major_python};g' $STAGE_PATH/$i
    # remove backup file
    rm -f $STAGE_PATH/$i.orig
  done

  # TODO fix bash scripts to not use abs path!
}

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_python_pyqt5() {
  try mkdir -p $BUILD_python_pyqt5
  cd $BUILD_python_pyqt5

  # check marker
  if [ -f .patched ]; then
    return
  fi

  touch .patched
}

function shouldbuild_python_pyqt5() {
  if python_package_installed PyQt5; then
    DO_BUILD=0
  fi
}

# function called to build the source code
function build_python_pyqt5() {
  try rsync -a $BUILD_python_pyqt5/ $BUILD_PATH/python_pyqt5/build-$ARCH/
  try cd $BUILD_PATH/python_pyqt5/build-$ARCH

  push_env

  try $PYCONFIGURE \
    --confirm-license \
    --stubsdir=$QGIS_SITE_PACKAGES_PATH/PyQt5 \
    --sipdir=$STAGE_PATH/share/sip/PyQt5 \
    --bindir=$STAGE_PATH/bin \
    --sip-incdir=$STAGE_PATH/include \
    --destdir=$QGIS_SITE_PACKAGES_PATH \
    --disable=QAxContainer \
    --disable=QtX11Extras \
    --disable=QtWinExtras \
    --disable=Enginio \
    --designer-plugindir=$STAGE_PATH/share/plugins \
    --qml-plugindir=$STAGE_PATH/share/plugins

  try $MAKESMP
  try $MAKE install
  try $MAKE clean

  fix_python_pyqt5_paths

  pop_env
}

function postbuild_python_pyqt5() {
   if ! python_package_installed PyQt5; then
      error "Missing python package PyQt5"
   fi
}
