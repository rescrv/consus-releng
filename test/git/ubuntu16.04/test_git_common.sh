#!/bin/bash

set -e

GLOBAL_INSTALL_SCRIPT=doc/install/git
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

extract_script_from_dist "${CONSUS_GIT_PREREQ_INSTALL}" /tmp/git_prereq_install.sh
extract_script_from_dist "${GLOBAL_INSTALL_SCRIPT}" /tmp/install.sh
apt-get clean
. /tmp/git_prereq_install.sh
cd /tmp
cp -R "${MINION_SOURCE_PO6}" .
cp -R "${MINION_SOURCE_E}" .
cp -R "${MINION_SOURCE_BUSYBEE}" .
cp -R "${MINION_SOURCE_REPLICANT}" .
cp -R "${MINION_SOURCE_TREADSTONE}" .
cp -R "${MINION_SOURCE_CONSUS}" .
. /tmp/install.sh
