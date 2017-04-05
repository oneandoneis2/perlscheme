#!/usr/bin/env perl

use strict;
use warnings;
use feature 'say';
use Data::Dumper;
$Data::Dumper::Sortkeys = 1;
$Data::Dumper::Indent = 1;
$Data::Dumper::Maxdepth = 2;

use lib 'lib';
use Parse;


my $thing = Parse::tokens('(  (abc de    "f g" h)  )');
while (1) {
    my $foo = $thing->();
    last unless $foo;
    say Dumper $foo;
}
