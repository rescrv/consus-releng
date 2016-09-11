#!/bin/zsh

set -e

# XXX check version matches version in manual
export DOC_TAR_GZ=${MINION_ARTIFACT_DIST_CONSUS_TAR_GZ}
export DOC_NAME=consus
export DOC_ARTIFACT=MINION_ARTIFACT_DOC_CONSUS
exec /root/common.zsh
