#!/bin/bash

set -e

cp -R ${MINION_SOURCE_PO6} /tmp
cd /tmp/po6

export PATH=/tmp/install/bin:${PATH}
export PKG_CONFIG_PATH=/tmp/install/lib/pkgconfig

autoreconf -ivf
./configure --prefix=/tmp/install
make -j
make -j distcheck
echo MINION_ARTIFACT_DIST_PO6_TAR_GZ=$(find $(pwd) -iname '*'.tar.gz)
echo MINION_ARTIFACT_DIST_PO6_TAR_BZ2=$(find $(pwd) -iname '*'.tar.bz2)
