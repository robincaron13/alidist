package: cpprestsdk
version: v2.10.18
tag: 2.10.18
source: https://github.com/Microsoft/cpprestsdk
requires:
  - boost
  - OpenSSL:(?!osx)
build_requires:
  - CMake
---
#!/bin/sh

case $ARCHITECTURE in
  osx*) 
    [[ ! $BOOST_ROOT ]] && BOOST_ROOT=$(brew --prefix boost)
    [[ ! $OPENSSL_ROOT ]] && OPENSSL_ROOT=$(brew --prefix openssl@1.1)
  ;;
esac

cmake "$SOURCEDIR/Release"                              \
      -DCMAKE_INSTALL_PREFIX=$INSTALLROOT               \
      -DBUILD_TESTS=OFF                                 \
      -DBUILD_SAMPLES=OFF                               \
      -DCMAKE_BUILD_TYPE=Debug                          \
      -DCMAKE_CXX_FLAGS=-Wno-error=conversion           \
      -DCPPREST_EXCLUDE_WEBSOCKETS=ON                   \
      -DCMAKE_INSTALL_LIBDIR=lib                        \
      ${BOOST_REVISION:+-DBOOST_ROOT=$BOOST_ROOT}       \
      ${OPENSSL_ROOT:+-DOPENSSL_ROOT_DIR=$OPENSSL_ROOT}

make ${JOBS:+-j $JOBS}
make install

#ModuleFile
mkdir -p etc/modulefiles
alibuild-generate-module --lib > etc/modulefiles/$PKGNAME
cat >> etc/modulefiles/$PKGNAME <<EoF
# Our environment
set CPPRESTSDK_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
EoF
mkdir -p $INSTALLROOT/etc/modulefiles && rsync -a --delete etc/modulefiles/ $INSTALLROOT/etc/modulefiles
