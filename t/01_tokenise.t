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
    is_deeply( $tokens->(), ['symbol', 'a_symbol'], 'Parsed simple symbol');
}

{
    my $tokens = Parse::tokens('a_symbol another_symbol');
    is_deeply( $tokens->(), ['symbol', 'a_symbol'], 'Parsed first symbol');
    is_deeply( $tokens->(), ['symbol', 'another_symbol'], 'Parsed second symbol');
}

{
    my $tokens = Parse::tokens('123');
    is_deeply( $tokens->(), ['number', 123], 'Got number');
}

{
    my $tokens = Parse::tokens('-123');
    is_deeply( $tokens->(), ['number', -123], 'Got number');
}

{
    my $tokens = Parse::tokens('123.45');
    is_deeply( $tokens->(), ['number', 123.45], 'Got number');
}

{
    my $tokens = Parse::tokens('-123.45');
    is_deeply( $tokens->(), ['number', -123.45], 'Got number');
}

{
    my $tokens = Parse::tokens('(   ))');
    is_deeply( $tokens->(), ['open-paren'], 'Parsed first paren');
    is_deeply( $tokens->(), ['close-paren'], 'Parsed first close-paren');
    is_deeply( $tokens->(), ['close-paren'], 'Parsed second close-paren');
}

{
    my $tokens = Parse::tokens('"a simple string"');
    is_deeply( $tokens->(), ['string', "a simple string"], 'Parsed simple string');
}

{
    my $tokens = Parse::tokens('"a string with \" an escaped quote"');
    is_deeply( $tokens->(), ['string', 'a string with " an escaped quote'], 'Parsed escaped-quote string');
}

{
    my $tokens = Parse::tokens('(a (complex "string" "and \"symbol\""   test 12 -13))');
    is_deeply( $tokens->(), ['open-paren'], 'Got first paren');
    is_deeply( $tokens->(), ['symbol', 'a'], 'Got first symbol');
    is_deeply( $tokens->(), ['open-paren'], 'Got second paren');
    is_deeply( $tokens->(), ['symbol', 'complex'], 'Got second symbol');
    is_deeply( $tokens->(), ['string', 'string'], 'Got first string');
    is_deeply( $tokens->(), ['string', 'and "symbol"'], 'Got second string');
    is_deeply( $tokens->(), ['symbol', 'test'], 'Got third symbol');
    is_deeply( $tokens->(), ['number',12], 'Got first number');
    is_deeply( $tokens->(), ['number',-13], 'Got second number');
    is_deeply( $tokens->(), ['close-paren'], 'Got first close-paren');
    is_deeply( $tokens->(), ['close-paren'], 'Got second close-paren');
}

{
    my $tokens = Parse::tokens('(first s-expression)(second');
    is_deeply( $tokens->('s-expression'), ['open-paren'], 'Got first paren');
    is_deeply( $tokens->(')'), ['symbol','first'], 'Got first symbol');
    is_deeply( $tokens->(), ['symbol','s-expression'], 'Got second symbol');
    is_deeply( $tokens->(), ['close-paren'], 'Got first close-paren');
    is_deeply( $tokens->(), ['open-paren'], 'Got second paren');
    is_deeply( $tokens->(), ['symbol','second'], 'Got first symbol of second sexpr');
    is_deeply( $tokens->(), ['symbol','s-expression'], 'Got second symbol of second sexpr');
    is_deeply( $tokens->(), ['close-paren'], 'Got second close-paren');
}

done_testing();
