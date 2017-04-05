package Parse;

use strict;
use warnings;

sub tokens {
    my $input = shift;
    my $building_string = 0;
    my $string_escape = 0;
    my $string = '';
    return sub {
        TOKEN: {
          if ($building_string) {
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

1;
