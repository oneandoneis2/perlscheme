package Parse;

use strict;
use warnings;

sub tokens {
    my $input = shift;
    my $next_input = '';
    my $building_string = 0;
    my $string_escape = 0;
    my $string = '';
    return sub {
        # Accept new input if supplied
        my $new_input = shift;
        $next_input .= ' ' . $new_input if $new_input;

        # Having sorted the input, start tokenising
        TOKEN: {
          # If original input is exhausted, use new input if we have any
          if ($input =~ /\G$/gcx && $next_input) {
              $input = $next_input;
              $next_input = '';
              redo TOKEN
          }

          # We have input to work with, are we building a string?
          elsif ($building_string) {
            if ($input =~ /\G " /gcx) {
                if ($string_escape) {
                    $string .= '"';
                    $string_escape = 0;
                    redo TOKEN
                }
                else {
                    my $completed_string = $string;
                    $string = '';
                    $building_string = 0;
                    return ['string', $completed_string]
                }
            }
            if ($input =~ /\G \\  /gcx) {
                $string_escape = 1;
                redo TOKEN
            }
            if ($input =~ /\G (.) /gcx) {
                if ($string_escape) {
                    $string .= '\\';
                    $string_escape = 0;
                }
                $string .= $1;
                redo TOKEN
            }
          }
          # Not building a string, must be symbols!
          else {
            if ($input =~ /\G \( /gcx) {
                return ['open-paren']
            }
            if ($input =~ /\G \) /gcx) {
                return ['close-paren']
            }
            if ($input =~ /\G " /gcx) {
                $building_string = 1;
                redo TOKEN
            }
            if ($input =~ /\G \s+ /gcx) {
                redo TOKEN
            }
            if ($input =~ /\G (-?\d+(\.\d+)?) /gcx) {
                return ['number', $1]
            }
            if ($input =~ /\G ([^"() ]+) /gcx) {
                return ['symbol', $1]
            }
            return;
          }
        }
    }
}

sub is_symbol { my $token = shift; return $token->[0] eq 'symbol' }
sub is_string { my $token = shift; return $token->[0] eq 'string' }
sub is_number { my $token = shift; return $token->[0] eq 'number' }
sub is_atom {
    my $token = shift;
    return ( is_symbol($token)
        || is_string($token)
        || is_number($token))
}

1;
