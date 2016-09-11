#!/bin/zsh

set -e

export LANG=en_US.UTF-8
export LANGUAGE=en_US:en
export LC_ALL=en_US.UTF-8

mkdir /tmp/doc
cd /tmp/doc
tar xzvf ${DOC_TAR_GZ}
cd ${DOC_NAME}*/doc
make

DOC_ROOT=$(basename ${DOC_TAR_GZ} | sed -e 's/.tar.gz//')
mv ${DOC_NAME}.pdf ${DOC_ROOT}.pdf
echo ${DOC_ARTIFACT}_PDF=`pwd`/${DOC_ROOT}.pdf

DOC_VERSION=$(echo ${DOC_ROOT} | sed -e "s/${DOC_NAME}-//")
python /root/html.py ${DOC_NAME} ${DOC_VERSION}
mv html ${DOC_ROOT}_html
tar czvf ${DOC_ROOT}_html.tar.gz ${DOC_ROOT}_html
echo ${DOC_ARTIFACT}_HTML=`pwd`/${DOC_ROOT}_html.tar.gz
