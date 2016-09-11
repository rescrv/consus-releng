#!/bin/zsh

set -e

# XXX check version matches version in manual
export DOC_TAR_GZ=${MINION_ARTIFACT_DIST_REPLICANT_TAR_GZ}
export DOC_NAME=replicant
export DOC_ARTIFACT=MINION_ARTIFACT_DOC_REPLICANT
exec /root/common.zsh
