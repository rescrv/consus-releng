#!/bin/bash

set -e

GLOBAL_INSTALL_SCRIPT=doc/install/linux-amd64
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

extract_script_from_dist "${GLOBAL_INSTALL_SCRIPT}" /tmp/install.sh

mkdir -p /tmp/bin
cd /tmp/bin
cp "${MINION_ARTIFACT_BIN_LINUX_AMD64_TAR_GZ}" .
. /tmp/install.sh

extract_script_from_dist "${CONSUS_PKG_PREREQ_INSTALL}" /tmp/pkg_prereq_install.sh
cd /
. /tmp/pkg_prereq_install.sh

mkdir -p /tmp/tests
cd /tmp/tests
tar xzf "${MINION_ARTIFACT_DIST_CONSUS_TESTS_TAR_GZ}"
cd "/tmp/tests/consus-${CONSUS_VERSION}"
export CONSUS_SRCDIR=`pwd`
rm test/demo.gremlin
for x in test/*-node-*-dc-cluster.gremlin
do
    echo $x
    $x
done

extract_script_from_dist "${CONSUS_PYTHON_PREREQ_INSTALL}" /tmp/python_prereq_install.sh
cd /
. /tmp/python_prereq_install.sh
export PKG_CONFIG_PATH=/usr/local/consus/lib/pkgconfig

tar xzf "${MINION_ARTIFACT_DIST_CONSUS_TAR_GZ}" -C /tmp/tarball "consus-${CONSUS_VERSION}/bindings/python"
cd "/tmp/tarball/consus-${CONSUS_VERSION}/bindings/python"
python setup.py install

cd "/tmp/tests/consus-${CONSUS_VERSION}"
for x in `find ./ -type f -iname '*.gremlin' -executable | sort`
do
    echo $x
    $x
done
