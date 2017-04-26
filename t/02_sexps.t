#!/usr/bin/env perl

use strict;
use warnings;
use feature 'say';
use Test::More;
use Data::Dumper;
$Data::Dumper::Sortkeys = 1;
$Data::Dumper::Indent = 1;
$Data::Dumper::Maxdepth = 2;

use lib 'lib';
use Parse;

{
    my $tokens = Parse::tokens('a_symbol');
    my $token = $tokens->();
    ok( Parse::is_symbol($token), "Correctly handled symbol as symbol" );
    ok( !Parse::is_string($token), "Correctly handled string as symbol" );
    ok( !Parse::is_number($token), "Correctly handled number as symbol" );
}

{
    my $tokens = Parse::tokens('123');
    my $token = $tokens->();
    ok( !Parse::is_symbol($token), "Correctly handled symbol as number" );
    ok( !Parse::is_string($token), "Correctly handled string as number" );
    ok( Parse::is_number($token), "Correctly handled number as number" );
}

{
    my $tokens = Parse::tokens('"foo"');
    my $token = $tokens->();
    ok( !Parse::is_symbol($token), "Correctly handled symbol as string" );
    ok( Parse::is_string($token), "Correctly handled string as string" );
    ok( !Parse::is_number($token), "Correctly handled number as string" );
}

{
    my $tokens = Parse::tokens('foo');
    ok( Parse::is_atom($tokens->('123')), "Correctly handled symbol as atom" );
    ok( Parse::is_atom($tokens->('"flibble"')), "Correctly handled number as atom" );
    ok( Parse::is_atom($tokens->('(')), "Correctly handled string as atom" );
    ok( !Parse::is_atom($tokens->(')')), "Correctly handled open-paren as atom" );
    ok( !Parse::is_atom($tokens->()), "Correctly handled close-paren as atom" );
}

done_testing();
