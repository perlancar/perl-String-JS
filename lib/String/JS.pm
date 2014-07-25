package String::JS;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use JSON;
my $json = JSON->new->allow_nonref;

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(
                       encode_js_string
                       decode_js_string
               );

sub encode_js_string {
    my $str = shift;
    no warnings 'uninitialized'; # shut up warning when $str is undef
    $json->encode("$str");
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

=head2 encode_js_string($str) => STR

Encode Perl string C<$str> to its JavaScript literal representation using double
quotes (C<">). This is currently implemented using JSON encoding.

An option to produce literal representation using single quotes (C<'>) will be
provided in the future.

Will die on failure.

=head2 decode_js_string($js_str) => STR

Given a JavaScript string literal representation in C<$js_str>, decode to get
the value.

Currently implemented using JSON decoding of stringified C<$js_str>.

Currently does not support JavaScript string representation that uses single
quotes (C<'>).

Will die on failure.


=head1 SEE ALSO

L<JSON>

=cut
