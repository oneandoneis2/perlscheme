#!/usr/bin/env perl

use strict;
use warnings;
use feature 'say';
use Data::Dumper;
$Data::Dumper::Sortkeys = 1;
$Data::Dumper::Indent = 1;
$Data::Dumper::Maxdepth = 2;

sub tokens {
    my $input = shift;
    return sub {
        TOKEN: {
            if ($input =~ /\G \( /gcx) {
                return ['open-paren']
            }
            if ($input =~ /\G \) /gcx) {
                return ['close-paren']
            }
            if ($input =~ /\G \s+ /gcx) {
                redo TOKEN
            }
            if ($input =~ /\G ([^() ]+) /gcx) {
                return ['symbol', $1]
            }
            return;
        }
    }
}

my $thing = tokens("(  (abc de    f g)  )");
while (1) {
    my $foo = $thing->();
    last unless $foo;
    say Dumper $foo;
}
