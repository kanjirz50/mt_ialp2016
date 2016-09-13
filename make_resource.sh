#!/bin/sh

ROOT=$(cd $(dirname $0);pwd)
SCRIPT_DIR=${ROOT}/script

if [ -e ${ROOT}/corpus/baseline -a -e ${ROOT}/corpus/nc_corpus ]; then
    echo "Corpus extracting has been done."
else
    echo "Start to extract."
    tar xvf ${ROOT}/corpus/corpora.tar.bz2 -C ${ROOT}/corpus
fi

if [ -e ${ROOT}/resource/kftt-data-1.0 ]; then
    echo "Original kftt has been downloaded."
else
    echo "Start downloading original kftt corpus."
    wget http://www.phontron.com/kftt/download/kftt-data-1.0.tar.gz -P resource
fi

if [ -e ${ROOT}/resource/kftt-data-1.0 ]; then
    echo "Original kftt has already unzipped."
else
    tar zxvf ./resource/kftt-data-1.0.tar.gz -C resource
fi

KFTT_ORIG_DIR=${ROOT}/resource/kftt-data-1.0/data/orig
OUT_DIR=${ROOT}/kftt-cleaned/orig

kftt_file_array=("kyoto-test" "kyoto-train" "kyoto-tune" "kyoto-dev")
for file in ${kftt_file_array[@]}
do
    echo "Preprocessing ${file}.ja"
    cat ${KFTT_ORIG_DIR}/${file}.ja | perl ${SCRIPT_DIR}/ja_prepro.pl > ${OUT_DIR}/${file}.ja
    echo "Preprocessing ${file}.en"
    cat ${KFTT_ORIG_DIR}/${file}.en | perl ${SCRIPT_DIR}/en_prepro.pl > ${OUT_DIR}/${file}.en
done
