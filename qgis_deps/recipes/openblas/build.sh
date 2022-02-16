function build_openblas() {
  try cd $BUILD_PATH/openblas/build-$ARCH

  push_env

  export CFLAGS="$CFLAGS -mmacosx-version-min=$MACOSX_DEPLOYMENT_TARGET"
  # lapacke_sggsvd_work.c:48:9: error: implicit declaration of function 'sggsvd_' is invalid in C99 [-Werror,-Wimplicit-function-declaration]
  export CFLAGS="$CFLAGS -Wno-implicit-function-declaration"
  export CXXFLAGS="$CFLAGS"

  # Contains FORTRAN LAPACK sources
  export DYNAMIC_ARCH=1
  export USE_OPENMP=0 # ? this is 1 in homebrew..?..
  export NO_AVX512=1

  try $MAKESMP FC=gfortran libs netlib shared
  try $MAKE install PREFIX=$STAGE_PATH

  unset DYNAMIC_ARCH
  unset USE_OPENMP
  unset NO_AVX512

  pop_env
}