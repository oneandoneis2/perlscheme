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
sub is_close { my $token = shift; return $token->[0] eq 'close-paren' }
sub is_open { my $token = shift; return $token->[0] eq 'open-paren' }
sub is_atom {
    my $token = shift;
    return ( is_symbol($token)
        || is_string($token)
        || is_number($token))
}

sub build_s {
    # Turns an S-expression into a data structure
    # The array of tokens must contain the symbols for a complete s-expr
    # Nested s-exprs are okay (yay mutual recursion!)
    my $tokens = shift;
    my $token = shift @$tokens;
    if (is_atom($token)) {
        # Atoms require no further processing
        return $token;
    }
    elsif (is_open($token)) {
        # Lists require their own special handling
        return make_list($tokens);
    }
}

sub make_list {
    my $tokens = shift;
    my $list = [];
    # We're making a list, so push its components into the array one by one
    while (@$tokens) {
        # Check if we've reached the end of the list yet
        if (is_close($tokens->[0])) {
            shift @$tokens; # In case we're nested, purge this list's ")"
            return $list;
        }
        else {
            # Not at the end, so handle what's next - whether it's
            # a symbol or a list.
            push @$list, build_s($tokens);
        }
    }
}

1;
