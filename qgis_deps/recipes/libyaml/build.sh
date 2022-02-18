function build_libyaml() {
  try cd ${DEPS_BUILD_PATH}/libyaml/build-$ARCH
  push_env

  try ./bootstrap
  patch_configure_file configure
  try ${CONFIGURE} --disable-dependency-tracking

  check_file_configuration config.status
  try $MAKESMP
  try $MAKESMP install

  pop_env
}
