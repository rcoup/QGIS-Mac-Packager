function build_brotli() {
  try mkdir -p $BUILD_PATH/brotli/build-$ARCH
  try cd $BUILD_PATH/brotli/build-$ARCH

  push_env

  try $CMAKE \
  $BUILD_brotli .

  check_file_configuration CMakeCache.txt

  try $NINJA
  try $NINJA_INSTALL

  try install_name_tool -id $STAGE_PATH/lib/$LINK_libbrotlicommon $STAGE_PATH/lib/$LINK_libbrotlicommon
  try install_name_tool -change $BUILD_PATH/brotli/build-$ARCH/$LINK_libbrotlidec $STAGE_PATH/lib/$LINK_libbrotlidec $STAGE_PATH/lib/$LINK_libbrotlicommon
  try install_name_tool -change $BUILD_PATH/brotli/build-$ARCH/$LINK_libbrotlicommon $STAGE_PATH/lib/$LINK_libbrotlicommon $STAGE_PATH/lib/$LINK_libbrotlicommon

  try install_name_tool -id $STAGE_PATH/lib/$LINK_libbrotlidec $STAGE_PATH/lib/$LINK_libbrotlidec
  try install_name_tool -change $BUILD_PATH/brotli/build-$ARCH/$LINK_libbrotlidec $STAGE_PATH/lib/$LINK_libbrotlidec $STAGE_PATH/lib/$LINK_libbrotlidec
  try install_name_tool -change $BUILD_PATH/brotli/build-$ARCH/$LINK_libbrotlicommon $STAGE_PATH/lib/$LINK_libbrotlicommon $STAGE_PATH/lib/$LINK_libbrotlidec

  pop_env
}
