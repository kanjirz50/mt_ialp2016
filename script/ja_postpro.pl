#! /usr/bin/env perl

use strict;
use warnings;
use utf8;
binmode STDIN, ':utf8';
binmode STDOUT, ':utf8';
binmode STDERR, ':utf8';

while(<STDIN>) {
    s/(\d) /\1/g;
    s/(\d+)(\D)/\1 \2/g;
    print $_;
}
