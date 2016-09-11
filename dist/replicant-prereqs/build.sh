#!/bin/bash

set -e

tar xzvf ${MINION_ARTIFACT_PREREQS_BUSYBEE_INSTALL_DIR} -C /tmp

export PATH=/tmp/install/bin:${PATH}
export PKG_CONFIG_PATH=/tmp/install/lib/pkgconfig

# install busybee
cd /tmp
tar xzvf ${MINION_ARTIFACT_DIST_BUSYBEE_TAR_GZ}
cd busybee-*

./configure --prefix=/tmp/install
make -j
make -j distcheck
make -j install

# build tarball
tar czvf /tmp/install.tar.gz -C /tmp install
echo MINION_ARTIFACT_PREREQS_REPLICANT_INSTALL_DIR=/tmp/install.tar.gz
