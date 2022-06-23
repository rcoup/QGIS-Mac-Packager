#!/bin/bash

DESC_python_pymssql="Python binding of MSSQL"

# need to keep in sync with hdf5

DEPS_python_pymssql=(python freetds python_packages)

# default build path
BUILD_python_pymssql=${DEPS_BUILD_PATH}/python_pymssql/v${VERSION_python_pymssql}

# default recipe path
RECIPE_python_pymssql=$RECIPES_PATH/python_pymssql

# function called after all the compile have been done
function postbuild_python_pymssql() {
   if ! python_package_installed_verbose pymssql; then
      error "Missing python package pymssql"
   fi
}

# function to append information to config file
function add_config_info_python_pymssql() {
  append_to_config_file "# python_pymssql-${VERSION_python_pymssql}: ${DESC_python_pymssql}"
  append_to_config_file "export VERSION_python_pymssql=${VERSION_python_pymssql}"
}