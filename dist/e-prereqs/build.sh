#!/bin/bash

set -e

cd /tmp
tar xzvf ${MINION_ARTIFACT_DIST_PO6_TAR_GZ}
cd libpo6-*

export PATH=/tmp/install/bin:${PATH}
export PKG_CONFIG_PATH=/tmp/install/lib/pkgconfig

./configure --prefix=/tmp/install
make -j
make -j distcheck
make -j install
tar czvf /tmp/install.tar.gz -C /tmp install
echo MINION_ARTIFACT_PREREQS_E_INSTALL_DIR=/tmp/install.tar.gz
