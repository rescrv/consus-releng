#!/bin/bash

set -e

function package_name
{
    basename $1 | sed -e 's/.tar.gz//'
}

CONSUS_ROOT=`package_name ${MINION_ARTIFACT_DIST_CONSUS_TAR_GZ}`

CUSTOM_PREFIX=/usr/local/consus
CUSTOM_CPPFLAGS="-I${CUSTOM_PREFIX}/include"
CUSTOM_CFLAGS="-fPIC -fpic -static-libgcc -static-libstdc++"
CUSTOM_CXXFLAGS="-fPIC -fpic -static-libgcc -static-libstdc++"
CUSTOM_LDFLAGS="-static-libgcc -static-libstdc++"

export PKG_CONFIG_PATH=${CUSTOM_PREFIX}/lib/pkgconfig

function configure_make_install
{
    TARBALL="$1"
    shift
    NAME="$1"
    shift
    LICENSE="$1"
    shift
    cd /tmp
    tar xvf ${TARBALL}
    cd /tmp/${NAME}*
    ./configure \
        CPPFLAGS="${CUSTOM_CPPFLAGS}" \
        CFLAGS="${CUSTOM_CFLAGS}" \
        CXXFLAGS="${CUSTOM_CXXFLAGS}" \
        LDFLAGS="${CUSTOM_LDFLAGS}" \
        --disable-shared \
        --prefix=${CUSTOM_PREFIX} $@
    make -j
    make install
    cp ${LICENSE} ${CUSTOM_PREFIX}/licenses/$(basename $(pwd) | sed -e 's/sparsehash-sparsehash-/sparsehash-/g')-license
    echo $(basename $(pwd)) | sed -e 's/sparsehash-sparsehash-/sparsehash-/g' >> ${CUSTOM_PREFIX}/licenses/README
}

function rebuild_shared_libs
{
    ./configure \
        CPPFLAGS="${CUSTOM_CPPFLAGS}" \
        CFLAGS="${CUSTOM_CFLAGS}" \
        CXXFLAGS="${CUSTOM_CXXFLAGS}" \
        LDFLAGS="${CUSTOM_LDFLAGS}" \
        --prefix=${CUSTOM_PREFIX}
    sed -i -e 's,postdeps="-lstdc++ ,postdeps="/usr/lib/gcc/x86_64-linux-gnu/4.8/libstdc++.a ,g' ./libtool
    find ./ -type f '(' -iname '*.c' -o -iname '*.h' -o -iname '*.cc' ')'  -exec touch {} \;
    make LDFLAGS='-Wc,-static-libgcc -Wc,-static-libstdc++' -j $@
    make -t
    make -t install
    make install
}

# preserve license notices
mkdir -p ${CUSTOM_PREFIX}/licenses
cat > ${CUSTOM_PREFIX}/licenses/README << EOF
Consus relies upon several open source projects.

This binary distribution is built from the following projects, whose respective
licenses may be found in this directory.

EOF

############################# External Dependencies ############################

# build popt
configure_make_install "${MINION_SOURCE_POPT_TAR_GZ}" popt COPYING --disable-nls
# build glog
configure_make_install "${MINION_SOURCE_GLOG_TAR_GZ}" glog COPYING
# build sparsehash
configure_make_install "${MINION_SOURCE_SPARSEHASH_TAR_GZ}" sparsehash COPYING
# build LevelDB
cd /tmp
tar xzvf "${MINION_SOURCE_LEVELDB_TAR_GZ}"
cd /tmp/leveldb*
make -j
cp -R include/leveldb ${CUSTOM_PREFIX}/include
cp out-static/libleveldb.a ${CUSTOM_PREFIX}/lib
cp LICENSE ${CUSTOM_PREFIX}/licenses/$(basename $(pwd))-license
echo $(basename $(pwd)) >> ${CUSTOM_PREFIX}/licenses/README

######################## Consus-Maintained Dependencies ########################

# build po6
configure_make_install "${MINION_ARTIFACT_DIST_PO6_TAR_GZ}" libpo6 LICENSE
# build e
configure_make_install "${MINION_ARTIFACT_DIST_E_TAR_GZ}" libe LICENSE
# build busybee
configure_make_install "${MINION_ARTIFACT_DIST_BUSYBEE_TAR_GZ}" busybee LICENSE
# build replicant
export POPT_LIBS="${CUSTOM_PREFIX}/lib/libpopt.a"
configure_make_install "${MINION_ARTIFACT_DIST_REPLICANT_TAR_GZ}" replicant LICENSE
rebuild_shared_libs librsm.la replicant-rsm-dlopen
# build treadstone
configure_make_install "${MINION_ARTIFACT_DIST_TREADSTONE_TAR_GZ}" libtreadstone LICENSE
# build consus
configure_make_install "${MINION_ARTIFACT_DIST_CONSUS_TAR_GZ}" consus LICENSE
rebuild_shared_libs libconsus-coordinator.la libconsus.la

chrpath -r '$ORIGIN/../../lib' "${CUSTOM_PREFIX}"/libexec/replicant*/replicant-rsm-dlopen

rm -rf ${CUSTOM_PREFIX}/include/busybee*.h
rm -rf ${CUSTOM_PREFIX}/include/e/
rm -rf ${CUSTOM_PREFIX}/include/glog/
rm -rf ${CUSTOM_PREFIX}/include/google/
rm -rf ${CUSTOM_PREFIX}/include/leveldb/
rm -rf ${CUSTOM_PREFIX}/include/po6/
rm -rf ${CUSTOM_PREFIX}/include/popt.h
rm -rf ${CUSTOM_PREFIX}/include/r*.h
rm -rf ${CUSTOM_PREFIX}/include/sparsehash/
rm -rf ${CUSTOM_PREFIX}/include/treadstone.h
rm -rf ${CUSTOM_PREFIX}/lib/lib[abd-qs-z]*
rm -rf ${CUSTOM_PREFIX}/lib/lib*.la
rm -rf ${CUSTOM_PREFIX}/lib/libreplicant.a
rm -rf ${CUSTOM_PREFIX}/lib/librsm.a
rm -rf ${CUSTOM_PREFIX}/lib/librsm.so
rm -rf ${CUSTOM_PREFIX}/lib/pkgconfig/[a-km-z]*
rm -rf ${CUSTOM_PREFIX}/lib/pkgconfig/lib[abd-z]*
rm -rf ${CUSTOM_PREFIX}/lib/python*
rm -rf ${CUSTOM_PREFIX}/share/doc/glog-0.3.4
rm -rf ${CUSTOM_PREFIX}/share/doc/sparsehash-2.0.2
rm ${CUSTOM_PREFIX}/libexec/consus-0.0.dev/libconsus-coordinator.so.0
rm ${CUSTOM_PREFIX}/libexec/consus-0.0.dev/libconsus-coordinator.so
rm ${CUSTOM_PREFIX}/libexec/consus-0.0.dev/libconsus-coordinator.la
rm ${CUSTOM_PREFIX}/libexec/consus-0.0.dev/libconsus-coordinator.a
mv ${CUSTOM_PREFIX}/libexec/consus-0.0.dev/libconsus-coordinator.so{.0.0.0,}
rm ${CUSTOM_PREFIX}/share/man/man3/popt.3
rmdir ${CUSTOM_PREFIX}/share/man/man3
rmdir ${CUSTOM_PREFIX}/share/doc

# report on what files are linked, and minimum versions for compatibility
cat > /tmp/report.txt << EOF
Consus linux-amd64 binary compatibility report
==============================================
EOF
/root/compatibility-check ${CUSTOM_PREFIX} >> /tmp/report.txt
cat /tmp/report.txt
cp /tmp/report.txt /tmp/${CONSUS_ROOT}.linux-amd64.txt
echo MINION_ARTIFACT_BIN_LINUX_AMD64_TXT=/tmp/${CONSUS_ROOT}.linux-amd64.txt

# build the distributable tarball
OUTPUT=/tmp/${CONSUS_ROOT}.linux-amd64.tar.gz
tar czvf ${OUTPUT} -C /usr/local consus/
echo MINION_ARTIFACT_BIN_LINUX_AMD64_TAR_GZ=${OUTPUT}
OUTPUT=/tmp/${CONSUS_ROOT}.linux-amd64.tar.bz2
tar cjvf ${OUTPUT} -C /usr/local consus/
echo MINION_ARTIFACT_BIN_LINUX_AMD64_TAR_BZ2=${OUTPUT}
