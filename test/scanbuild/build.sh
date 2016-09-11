#!/bin/bash

set -e
set -o pipefail

export PATH=/tmp/install/bin:${PATH}
export PKG_CONFIG_PATH=/tmp/install/lib/pkgconfig

function doit() {
    cd /tmp
    tar xzvf ${TARBALL}
    cd ${PKG}-*
    truncate -s 0 /tmp/${NAME}.txt
    scan-build-3.8 ./configure --prefix=/tmp/install > /tmp/${NAME}.txt 2>&1
    scan-build-3.8 -v make > /tmp/${NAME}.txt 2>&1
    make install
    echo MINION_ARTIFACT_CLANG_SCANBUILD_${NAMEU}_TXT=/tmp/${NAME}.txt
}

TARBALL=${MINION_ARTIFACT_DIST_PO6_TAR_GZ} PKG=libpo6 NAME=po6 NAMEU=PO6 doit
TARBALL=${MINION_ARTIFACT_DIST_E_TAR_GZ} PKG=libe NAME=e NAMEU=E doit
TARBALL=${MINION_ARTIFACT_DIST_TREADSTONE_TAR_GZ} PKG=libtreadstone NAME=treadstone NAMEU=TREADSTONE doit
TARBALL=${MINION_ARTIFACT_DIST_BUSYBEE_TAR_GZ} PKG=busybee NAME=busybee NAMEU=BUSYBEE doit
TARBALL=${MINION_ARTIFACT_DIST_REPLICANT_TAR_GZ} PKG=replicant NAME=replicant NAMEU=REPLICANT doit
TARBALL=${MINION_ARTIFACT_DIST_CONSUS_TAR_GZ} PKG=consus NAME=consus NAMEU=CONSUS doit
