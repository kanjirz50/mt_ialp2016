#!/bin/sh
##################################################
# This script is for IALP2016 SMT experiment.
# This script base is created by H.Matsumoto(http://eng.jnlp.org/matsumoto).
# Arragend by K.Takahashi.
#
# Usage: bash ex_nc_J2E.sh #1 #2
#   args
#     - #1: Moses directory
#     = #2: thread num
#     = #3: memory
##################################################

set -eu

# Settings
ORIG=ja   # Source language
TARGET=en # Target language
EX_COND=nc_corpus # corpus directory
MOSES_ROOT_DIR=$1 # Your Moses root directory ex. '/tools/src/mosesdecoder'
THREAD_NUM=$2
MEMORY=$3 # GB

# Get Paths
ABS_PATH=$(cd $(dirname $0) && pwd)
REPO_ROOT=$(dirname ${ABS_PATH})
EX=${EX_COND}_${ORIG^^}2${TARGET^^}

# Environment variables
export LC_ALL=C
export MOSES_ROOT=${MOSES_ROOT_DIR}

## making work directory
mkdir -p ${REPO_ROOT}/work
WORKSPACE=${REPO_ROOT}/work/${EX}
mkdir -p ${WORKSPACE}

## Training corpus
CORPUS_ROOT=${REPO_ROOT}/corpus
TRAIN_CORPUS_PATH=${CORPUS_ROOT}/${EX_COND}/kyoto-train
TUNE_CORPUS_PATH=${CORPUS_ROOT}/${EX_COND}/kyoto-tune

# Check multi thread tools
if test -e ${MOSES_ROOT}/tools/merge_alignment.py \
	-a -e ${MOSES_ROOT}/tools/mgiza \
	-a -e ${MOSES_ROOT}/tools/mkcls \
	-a -e ${MOSES_ROOT}/tools/snt2cooc; then
    echo "mgiza, mkcls, snt2cooc are available."
else
    echo "You have to install mgiza, mkcls, snt2cooc under the ${MOSES_ROOT}/tools/"
    exit
fi

# Training
bash ${ABS_PATH}/BuildSystem.sh \
     ${ORIG} \
     ${TARGET} \
     ${WORKSPACE} \
     ${TRAIN_CORPUS_PATH} \
     ${TUNE_CORPUS_PATH} \
     ${THREAD_NUM} \
     ${MEMORY}

# Translation
## Absolute path of Translation system
CORPUS_NAME=${TRAIN_CORPUS_PATH%/data*}
CORPUS_NAME=${CORPUS_NAME##*/}
SYSTEM_DIR=${WORKSPACE}/${CORPUS_NAME}_${ORIG^^}2${TARGET^^}_OPT
## Translation target absolute path
TRANSLATION_TARGET_PATH=${REPO_ROOT}/corpus/${EX_COND}/kyoto-test
## preserve directory
TRANSLATION_WORKPLACE=${SYSTEM_DIR}

bash ${ABS_PATH}/Translate.sh \
     ${SYSTEM_DIR} \
     ${TRANSLATION_TARGET_PATH} \
     ${TRANSLATION_WORKPLACE} \
     ${THREAD_NUM}

