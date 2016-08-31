#! /usr/bin/env perl

use strict;
use warnings;
use utf8;
binmode STDIN, ':utf8';
binmode STDOUT, ':utf8';
binmode STDERR, ':utf8';

while(<STDIN>) {
    print lc($_);
}
