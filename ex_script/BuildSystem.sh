#!/bin/sh
##########################################
# This script is for IALP2016 SMT experiment.
# This script base is created by H.Matsumoto(http://eng.jnlp.org/matsumoto).
# Arragend by K.Takahashi.
#
# 引数で指定されたコーパスを利用して翻訳機を構築する
#
# bash BuildSystem.sh #1 #2 #3 #4 #5 #6 #7
#
# 学習用コーパスやテストセットの拡張子で原言語、目的言語を識別する
# パラレルコーパスは２つファイルから成る.
# パラレルコーパスは位置で対応関係を取る.
# テストセットも同様
# 例: kyoto-train.en, kyoto-train.ja
#
# 引数説明:
# #1: 原言語の拡張子: ja
# #2: 目的言語の拡張子: en
# #3: 作業ディレクトリ(指定ディレクトリ以下に新規作業ディレクトリが作成される): /lab/matsumoto/KFTT/translation/
#          作成されるディレクトリ名は:(学習コーパス名)_(#1)2(#2)_OPT
#     もし任意の名前をつけたかったら
#         WORKSPACE_DIR=${WORKSPACE}/""
#     の""に名前を入れる
# #4: 学習コーパスのパス(最後の拡張子は不要): /lab/matsumoto/KFTT/translation/Experiments/Corpus/kyoto-train
# #5: チューニング用・セット・パス(最後の拡張子は不要): /lab/matsumoto/KFTT/translation/Experiments/Corpus/kyoto-tune
# #6: スレッド数
# #7: メモリ(GB)
# パスは絶対パスで記述すること
#
# 出力: 作業ディレクトリ以下にシステムが構築される
#
##########################################

ORIG=$1
TARGET=$2
WORKSPACE=$3
TRAIN_CORPUS_PATH=$4
TUNE_CORPUS_PATH=$5
THREAD_NUM=$6
WORK_MEMORY=$7

############ ENVIRONMENT SETUP ############
# moses本体ディレクトリ
DECODER_ROOT=${MOSES_ROOT}
SCRIPTS_DIR=$DECODER_ROOT/scripts

CORPUS_NAME=${TRAIN_CORPUS_PATH%/data*}
CORPUS_NAME=${CORPUS_NAME##*/}

echo "############ Create Save-Dir ############"
if test ${TUNE_CORPUS_PATH}; then
    WORKSPACE_DIR=${WORKSPACE}/${CORPUS_NAME}_${ORIG^^}2${TARGET^^}_OPT

else
    WORKSPACE_DIR=${WORKSPACE}/${CORPUS_NAME}_${ORIG^^}2${TARGET^^}
fi
echo "Workspace DIR:" ${WORKSPACE_DIR}

if test ! -e ${WORKSPACE_DIR}; then
    mkdir -p ${WORKSPACE_DIR}
    echo "Created Workspace:" ${WORKSPACE_DIR}
fi
echo ''

echo "############ DATA Preprocessing ############"
if test ! -e ${TRAIN_CORPUS_PATH}.cln.${ORIG} -o ! -e  ${TRAIN_CORPUS_PATH}.cln.${TARGET}; then
    echo "Cleaning lines for GIZA++"
    ${DECODER_ROOT}/scripts/training/clean-corpus-n.perl ${TRAIN_CORPUS_PATH} ${ORIG} ${TARGET} ${TRAIN_CORPUS_PATH}.cln 0 10000
    # 10000単語の1文は実質ないと考える。（clean-corpus-n.perlが不正な文字列を取り除くので活用）
else
    echo "Data had already been preprocessed."
fi
echo ""

############ Training ############
# Training Language Model: 5gram Kneser-Ney smoothed
echo "############ Training Language Model ##############"
if test ! -e ${WORKSPACE_DIR}/lm.${TARGET}.gz; then
    ${DECODER_ROOT}/bin/lmplz -o 5 -S ${WORK_MEMORY}G --text ${TRAIN_CORPUS_PATH}.cln.${TARGET} --arpa ${WORKSPACE_DIR}/lm.${TARGET}
    pigz -p ${THREAD_NUM} ${WORKSPACE_DIR}/lm.${TARGET}
else
    echo "Language Model had already been trained."
fi
LM_PATH=${WORKSPACE_DIR}/lm.${TARGET}.gz
echo "Language Model Path:" ${LM_PATH}

########## Train Translation Model ###########
# 高速処理化のために並列処理圧縮コマンドpigzを利用する
# 標準パッケージ管理でインストール可能: yum install pigz
echo "Training Translation Model"
if test -e ${TRAIN_CORPUS_PATH}.${ORIG} -a -e ${TRAIN_CORPUS_PATH}.${TARGET} -a ! -e ${WORKSPACE_DIR}/model/moses.ini; then
    echo "Training start"
    ${DECODER_ROOT}/scripts/training/train-model.perl \
	--root-dir ${WORKSPACE_DIR}  \
	-f ${ORIG} -e ${TARGET} \
	-corpus ${TRAIN_CORPUS_PATH}.cln \
	-alignment grow-diag-final-and -reordering wbe-msd-bidirectional-fe \
	-lm 0:5:${LM_PATH}:8 -external-bin-dir ${DECODER_ROOT}/tools \
	-mgiza -mgiza-cpus ${THREAD_NUM} \
	-parallel -cores ${THREAD_NUM} \
	-sort-compress pigz -sort-parallel ${THREAD_NUM} \
	-sort-batch-size 16381 \
	-sort-buffer-size ${WORK_MEMORY}G
else
    echo "Training has already finished."
fi

# Optimization
echo "Tuning"
echo "デコードを評価値に対して最適化する"
echo "By default, tuning is optimizing the BLEU score of translating the specified tuning set. You can also use other metrics, and even combinations of metrics."
if test -e ${TUNE_CORPUS_PATH}.${ORIG} -a -e ${TUNE_CORPUS_PATH}.${TARGET} -a ! -e ${WORKSPACE_DIR}/mert-work/moses.ini; then
    ${DECODER_ROOT}/scripts/training/mert-moses.pl \
    	${TUNE_CORPUS_PATH}.${ORIG} \
    	${TUNE_CORPUS_PATH}.${TARGET} \
    	${DECODER_ROOT}/bin/moses \
    	${WORKSPACE_DIR}/model/moses.ini  \
	--working-dir=${WORKSPACE_DIR}/mert-work \
    	--threads=${THREAD_NUM} \
    	--mertdir ${DECODER_ROOT}/bin/ | tee ${WORKSPACE_DIR}/mert.out
fi

# エンコーダー・コンフィグ・ファイル・パス出力
if test -e ${WORKSPACE_DIR}/mert-work/moses.ini; then
    echo ${WORKSPACE_DIR}/mert-work/moses.ini
else
    echo ${WORKSPACE_DIR}/model/moses.ini
fi
