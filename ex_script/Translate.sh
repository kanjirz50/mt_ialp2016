#!/bin/sh
##########################################
# 指定のシステムでテスト文を翻訳し、テスト文のシンボリック・リンクと出力を同ディレクトリに格納する
#
# bash Translate.sh #1 #2 #3 #4
# #1: 指定システム・ディレクトリの絶対パス
# #2: 翻訳対象文の絶対パス
# #3: 保存場所
# #4: スレッド数
#
##########################################
SYSTEM_DIR=$1
TRANSLATION_TARGET_PATH=$2
TRANSLATION_WORKPLACE=$3
THREAD_NUM=$4

DECODER_ROOT=${MOSES_ROOT}
SCRIPTS_DIR=$DECODER_ROOT/scripts


################# 設定 ####################
# 翻訳出力先ディレクトリ名解決
# 翻訳機名の取得:ディレクトリ名より
SYSTEM_NAME=${SYSTEM_DIR##*/}
SYSTEM_NAME=${SYSTEM_NAME%_*}
SYSTEM_TASK=${SYSTEM_NAME#*_}

# 原言語と対象言語の拡張子取得
ORIG_EXT=${SYSTEM_TASK%2*}
TARGET_EXT=${SYSTEM_TASK##*2}

# 翻訳対象ファイルのファイル名(拡張子なし)の取得
TARGET_FILE=${TRANSLATION_TARGET_PATH##*/}
TARGET_FILE_BASENAME=${TARGET_FILE%.*}

# 保存ディレクトリ生成
# 翻訳対象ファイル名_原言語2対象言語という命名規則
WORKSPACE_DIR=${TRANSLATION_WORKPLACE}

# 翻訳出力
# 原言語のファイル名と対象言語のファイル名が拡張子のみの違いとなるようにする
TRANSLATION_ORIG=${TRANSLATION_TARGET_PATH}.${ORIG_EXT,,}
TRANSLATION_RESULT=${WORKSPACE_DIR}/${TARGET_FILE_BASENAME}.${TARGET_EXT,,}
# 翻訳出力の結果保存先ディレクトリ生成, かつ翻訳対象文のシンボリック・リンクを張る
if test ! -e ${WORKSPACE_DIR}; then
    mkdir -p ${WORKSPACE_DIR}
fi
echo "シンボリックリンク"
echo $TRANSLATION_TARGET_PATH
echo $ORIG_EXT
echo $TRANSLATION_ORIG
if test ! -e $TRANSLATION_TARGET_PATH; then
    ln -s $TRANSLATION_TARGET_PATH $TRANSLATION_ORIG
fi


################### 翻訳処理 ##################
if test ! -e ${TRANSLATION_RESULT}; then
    # TUNED
    if test -e ${SYSTEM_DIR}/mert-work/moses.ini; then
	echo "Tuned-Translation"
	${DECODER_ROOT}/bin/moses \
	    -f ${SYSTEM_DIR}/mert-work/moses.ini \
	    --threads ${THREAD_NUM}\
	    < ${TRANSLATION_ORIG} \
	    > ${TRANSLATION_RESULT}
    # NotTUNED
    else
	echo "Intuned-Translation"
	${DECODER_ROOT}/bin/moses \
	    -f ${SYSTEM_DIR}/model/moses.ini \
	    --threads ${THREAD_NUM} \
	    < ${TRANSLATION_ORIG} \
	    > ${TRANSLATION_RESULT}
    fi
fi

echo "翻訳結果:" ${TRANSLATION_RESULT}
