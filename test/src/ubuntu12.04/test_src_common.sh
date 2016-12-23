#!/bin/bash

set -e

GLOBAL_INSTALL_SCRIPT=doc/install/source
CONSUS_VERSION=`echo ${MINION_ARTIFACT_DIST_CONSUS_TAR_GZ} | sed -e 's/.*consus-\(.*\).tar.gz/\1/'`

function extract_script_from_dist
{
    script_path=$1
    shift
    out_path=$1
    shift
    mkdir -p /tmp/tarball
    mkdir -p `dirname "${out_path}"`
    tar xzf "${MINION_ARTIFACT_DIST_CONSUS_TAR_GZ}" -C /tmp/tarball "consus-${CONSUS_VERSION}/${script_path}"
    if test ! -f "/tmp/tarball/consus-${CONSUS_VERSION}/${script_path}"
    then
        echo could not find script at "\"${script_path}\"" in the consus tarball
        exit 1
    fi
    cut -c 3- "/tmp/tarball/consus-${CONSUS_VERSION}/${script_path}" > "${out_path}"
}

extract_script_from_dist "${CONSUS_SRC_PREREQ_INSTALL}" /tmp/src_prereq_install.sh
extract_script_from_dist "${GLOBAL_INSTALL_SCRIPT}" /tmp/install.sh
apt-get clean
. /tmp/src_prereq_install.sh
cd /tmp
cp "${MINION_ARTIFACT_DIST_PO6_TAR_GZ}" .
cp "${MINION_ARTIFACT_DIST_E_TAR_GZ}" .
cp "${MINION_ARTIFACT_DIST_BUSYBEE_TAR_GZ}" .
cp "${MINION_ARTIFACT_DIST_REPLICANT_TAR_GZ}" .
cp "${MINION_ARTIFACT_DIST_TREADSTONE_TAR_GZ}" .
cp "${MINION_ARTIFACT_DIST_CONSUS_TAR_GZ}" .
. /tmp/install.sh
