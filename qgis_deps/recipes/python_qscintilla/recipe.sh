#!/bin/bash

DESC_python_qscintilla="QScintilla package for python"

# version of your package
# keep in SYNC with qscintilla receipt
VERSION_python_qscintilla=2.11.5

# dependencies of this recipe
# depends on PyQt5
DEPS_python_qscintilla=(python qscintilla python_sip python_pyqt5 python_packages)

# url of the package
URL_python_qscintilla=https://www.riverbankcomputing.com/static/Downloads/QScintilla/${VERSION_python_qscintilla}/QScintilla-${VERSION_python_qscintilla}.tar.gz

# md5 of the package
MD5_python_qscintilla=c31d77e1fcc218ed3f27458fa80d4dc9

# default build path
BUILD_python_qscintilla=${DEPS_BUILD_PATH}/python_qscintilla/$(get_directory $URL_python_qscintilla)

# default recipe path
RECIPE_python_qscintilla=$RECIPES_PATH/python_qscintilla

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_python_qscintilla() {
  cd $BUILD_python_qscintilla
  try rsync -a $BUILD_python_qscintilla/ ${DEPS_BUILD_PATH}/python_qscintilla/build-${ARCH}


  # without QtWidgets it cannot compile with
  # fatal error: 'QAbstractScrollArea' file not found
  # try ${SED} "s;# Work around QTBUG-39300.;pro.write('QT += widgets printsupport\\\n');g" Python/configure.py

}

function shouldbuild_python_qscintilla() {
  # If lib is newer than the sourcecode skip build
  if python_package_installed PyQt5.Qsci; then
    DO_BUILD=0
  fi
}



# function called after all the compile have been done
function postbuild_python_qscintilla() {
   if ! python_package_installed_verbose PyQt5.Qsci; then
      error "Missing python package qsci"
   fi
}

# function to append information to config file
function add_config_info_python_qscintilla() {
  append_to_config_file "# python_qscintilla-${VERSION_python_qscintilla}: ${DESC_python_qscintilla}"
  append_to_config_file "export VERSION_python_qscintilla=${VERSION_python_qscintilla}"
}