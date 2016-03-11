package String::JS;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use JSON::MaybeXS;
my $json = JSON::MaybeXS->new->allow_nonref;

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(
                       encode_js_string
                       decode_js_string
               );

my %esc = (
    "\n"   => "\\n",
    "\r"   => "\\r",
    "\x0b" => "\\v",
    "\t" => "\\t",
    "\b" => "\\b",
    "\f" => "\\f",
);

sub encode_js_string {
    my ($str, $mode) = @_;
    no warnings 'uninitialized'; # shut up warning when $str is undef
    if ($mode) {
        if ($mode == 1) {
            $str =~ s/([\\'])/\\$1/g;
            return qq('$str') unless $str =~ /[^\040-\176]/;  # fast exit
            $str =~ s/([\n\r\x0b\t\b\f])/$esc{$1}/g;
            $str =~ s/([\0-\037\177-\377])/sprintf('\\x%02x',ord($1))/eg;
            $str =~ s/([^\040-\176])/sprintf('\\u{%04x}',ord($1))/eg;
            return qq('$str');
        } elsif ($mode == 2) {
            $str =~ s/([\\'"])/\\\\$1/g;
            return qq('$str') unless $str =~ /[^\040-\176]/;  # fast exit
            $str =~ s/([\n\r\x0b\t\b\f])/\\$esc{$1}/g;
            $str =~ s/([\0-\037\177-\377])/sprintf('\\\\x%02x',ord($1))/eg;
            $str =~ s/([^\040-\176])/sprintf('\\\\u{%04x}',ord($1))/eg;
            return qq('$str');
        } else {
            die "Invalid mode, must be 0, 1, or 2";
        }
    } else {
        return $json->encode("$str");
    }
}

sub decode_js_string {
    my $str = shift;
    if ($str =~ /\A"/o) {
        $json->decode($str);
    } elsif ($str =~ /\A'/o) {
        die "Decoding JavaScript string with single quotes not yet implemented";
    } else {
        die "Invalid JavaScript string literal";
    }
}

1;
# ABSTRACT: Utilities for Javascript string literal representation

=head1 FUNCTIONS

=head2 encode_js_string($str[, $mode]) => STR

Encode Perl string C<$str> to its JavaScript literal representation using double
quotes (C<">). This is currently implemented using JSON encoding.

If C<$mode> is set to 1, will produce literal representation using single quotes
(C<'>) instead.

If C<$mode> is set to 2, will produce single-quoted JS string to be put inside a
double-quoted JS string literal, useful for producing for example jQuery
expression like:

 $("h2.contains('this is JS string inside another JS string')")

Will die on failure.

=head2 decode_js_string($js_str) => STR

Given a JavaScript string literal representation in C<$js_str>, decode to get
the value.

Currently implemented using JSON decoding of stringified C<$js_str>.

Currently does not support JavaScript string representation that uses single
quotes (C<'>).

Will die on failure.

=cut
