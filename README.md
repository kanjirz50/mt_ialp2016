# Pre-processing and Post-processing scripts for KFTT and NTCIR-7 corpus to improve SMT experiment(IALP2016)
Preprocessing scripts for SMT research(will be published in IALP2016)
These scripts is apllied for a research(Japanese Orthographical Normalization Do Not Work for Statistical Machine Translation).

These scripts make parallel corpus clear for Statistical Machine Translation research.
Target corpora are KFTT(The Kyoto Free Translation Task) and NTCIR-7(Pattent corpus).

# Usage

## Get scripts and create corpus

```sh
git clone https://github.com/kanjirz50/mt_ialp2016.git
cd mt_ialp2016
./make_corpus.sh
```

## Post-processing

`script/ja_postpro.pl` is a post processing-script for chunking numeric representations.
Because Japanese morphological analyzer, MeCab-UniDic segments numeric representations.
In English side, there is no boundary within a numeric representation.

> ex.
> 私は25歳です。 (I am 25 years old.)
> 私 は 2 5 歳 です。

```sh
cat word_segmented_japanese_text.ja | perl script/ja_postpro.pl
```

# Reference
- Graham Neubig, "The Kyoto Free Translation Task," http://www.phontron.com/kftt, 2011.
- Kazuhide Yamamoto and Kanji Takahashi. Japanese Orthographical Normalization Do Not Work for Statistical Machine Translation. Proceedings of the International Conference on Asian Language Processing (IALP 2016), Nov, 2016
