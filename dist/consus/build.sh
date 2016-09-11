#!/bin/bash

set -e

tar xzvf ${MINION_ARTIFACT_PREREQS_CONSUS_INSTALL_DIR} -C /tmp

cp -R ${MINION_SOURCE_CONSUS} /tmp
cd /tmp/consus

export PATH=/tmp/install/bin:${PATH}
export PKG_CONFIG_PATH=/tmp/install/lib/pkgconfig

autoreconf -ivf
./configure --prefix=/tmp/install
make -j
make -j distcheck
make consus-tests.tar.gz
mv consus-tests.tar.gz /tmp/consus-tests.tar.gz
echo MINION_ARTIFACT_DIST_CONSUS_TAR_GZ=$(find $(pwd) -iname '*'.tar.gz)
echo MINION_ARTIFACT_DIST_CONSUS_TAR_BZ2=$(find $(pwd) -iname '*'.tar.bz2)
echo MINION_ARTIFACT_DIST_CONSUS_TESTS_TAR_GZ=/tmp/consus-tests.tar.gz
