#!/usr/bin/env perl

use strict;
use warnings;
use feature 'say';
use Test::More;
use Data::Dumper;
$Data::Dumper::Sortkeys = 1;
$Data::Dumper::Indent = 1;

use lib 'lib';
use Parse;

# Primitive conversion from stream of symbols to array
# "Read" will do this properly but this is good neough for the tests
sub make_sexpr {
    my $tokens = shift;
    my $sexp = [];
    while (my $token = $tokens->()) {
        push @$sexp, $token;
    }
    return $sexp;
}

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

{
    my $tokens = Parse::tokens('(foo)');
    my $sexpr  = make_sexpr($tokens);
    my $ast = Parse::build_s($sexpr);
    is_deeply( $ast, [['symbol','foo']], 'Built single list');
}

{
    my $tokens = Parse::tokens('(foo bar baz)');
    my $sexpr  = make_sexpr($tokens);
    my $ast = Parse::build_s($sexpr);
    is_deeply( $ast, [['symbol','foo'],['symbol','bar'],['symbol','baz']], 'Built bigger list');
}

{
    my $tokens = Parse::tokens('(foo)');
    my $sexpr  = make_sexpr($tokens);
    my $ast = Parse::build_s($sexpr);
    is_deeply( $ast, [['symbol','foo']], 'Built simple symbol');
}

{
    my $tokens = Parse::tokens('(foo (bar) baz)');
    my $sexpr  = make_sexpr($tokens);
    my $ast = Parse::build_s($sexpr);
    is_deeply( $ast, [['symbol','foo'],[['symbol','bar']],['symbol','baz']], 'Built nested list');
}

{
    my $tokens = Parse::tokens('(one (two (3 4 "5") "six") (seven))');
    my $sexpr  = make_sexpr($tokens);
    my $ast = Parse::build_s($sexpr);
    is_deeply( $ast, [
        ['symbol','one'],
        [
            ['symbol','two'],
            [
                ['number', 3],
                ['number', 4],
                ['string', "5"]
            ],
            ['string','six']
        ],
        [
            ['symbol','seven']
        ]
    ], 'Built nested list');
}

done_testing();
