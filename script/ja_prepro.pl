#! /usr/bin/env perl

use strict;
use warnings;
use utf8;
binmode STDIN, ':utf8';
binmode STDOUT, ':utf8';
binmode STDERR, ':utf8';

while(<STDIN>) {
    s/（\p{Han}+[0-9元]+年）//g; # delete （平成28年）
    s/（\p{Han}+[0-9元]+）//g; # delete （平成28）
    s/\p{Han}+[0-9元]+年（([0-9]+年)）/$1/g; # replace 平成28年（2016年） to 2016年
    s/（\p{Hiragana}+）//g; # replace 雪舟（せっしゅう） to 雪舟
    print $_;
}
