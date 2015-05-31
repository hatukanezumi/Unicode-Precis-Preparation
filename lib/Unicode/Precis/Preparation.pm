#-*- perl -*-
#-*- coding: utf-8 -*-

package Unicode::Precis::Preparation;

use 5.006001;
use strict;
use warnings;

use base qw(Exporter);

our %EXPORT_TAGS = (
    'all' => [
        qw(prepare
            ValidUTF8 FreeFormClass IdentifierClass
            UNASSIGNED PVALID CONTEXTJ CONTEXTO DISALLOWED)
    ],
    'internal' => [qw(_lookup_prop _lookup_xprop)]
);
our @EXPORT_OK = (@{$EXPORT_TAGS{'all'}}, @{$EXPORT_TAGS{'internal'}});

our $VERSION    = '0.000_02';
our $XS_VERSION = $VERSION;
$VERSION = eval $VERSION;    # see L<perlmodstyle>

require XSLoader;
XSLoader::load('Unicode::Precis::Preparation', $XS_VERSION);

BEGIN { eval 'use Unicode::UCD'; }
my $UnicodeVersion;
if ($Unicode::UCD::VERSION) {
    $UnicodeVersion = Unicode::UCD::UnicodeVersion();
} else {
    # For Perl 5.6.x.
    $UnicodeVersion = '3.0';
}

sub prepare {
    my $string          = shift;
    my $stringclass     = shift || 0;
    my $unicode_version = shift || $UnicodeVersion;

    my ($unicode_major, $unicode_minor) = split /[.]/, $unicode_version;
    $unicode_minor ||= 0;

    _prepare($string, $stringclass, ($unicode_major << 4) + $unicode_minor);
}

1;
__END__

=encoding utf-8

=head1 NAME

Unicode::Precis::Preparation - RFC 7564 PRECIS Framework - Preparation

=head1 SYNOPSIS

  use Unicode::Precis::Preparation qw(:all);
  $result = prepare($string, IdentifierClass);

=head1 DESCRIPTION

L<Unicode::Precis::Preparation> prepares Unicode string or UTF-8 bytestring
according to PRECIS framework.

=head2 Function

=over

=item prepare ( $string, [ $stringclass ], [ $unicode_version ] )

Check if a string conforms to specified string class.

Parameters:

=over

=item $string

A string to be checked, Unicode string or bytestring.

Note that bytestring won't be upgraded to Unicode string but will be treated
as UTF-8 sequence.

=item $stringclass

One of the constants C<ValidUTF8> (default), C<IdentifierClass> (see RFC 7564)
or C<FreeFormClass> (ditto).

=item $unicode_version

If a version of Unicode is given, repertoire is restricted according to it.
By default, repertoire of Unicode version supported by Perl using this module
is available.

=back

Returns:

In scalar context:
True value if the string conforms to specified string class.
Otherwise false value.

In array context:
A list of pairs describing detail of result with these keys:

=over

=item C<result>

One of property values described in L</Constants>.

=item C<offset>

When the check fails,
offset from beginning of string.
Offset is based on byte for bytestring,
and based on character for Unicode string.

=item C<length>

When the check fails,
length of disallowed character.
Length is C<1> to C<4> for bytestring,
always C<1> for Unicode string
and undefined value for invalid sequence.

=item C<ord>

Unicode scalar value of character, when C<length> item is set.

=back

=back

=head2 Constants

=over

=item FreeFormClass

=item IdentifierClass

=item ValidUTF8

String classes.
C<ValidUTF8> is the extension by this module.

=item UNASSIGNED

=item PVALID

=item CONTEXTJ

=item CONTEXTO

=item DISALLOWED

Property values to represent results.
C<PVALID> means successful result.

=back

=head2 EXPORT

None are exported by default.
prepare() and constants may be exported by C<:all> tag.

=head1 SEE ALSO

L<Unicode::Precis> - coming late.

RFC 7564 I<PRECIS Framework: Preparation, Enforcement, and Comparison of
Internationalized Strings in Application Protocols>.
L<https://tools.ietf.org/html/rfc7564>.

=head1 AUTHOR

Hatuka*nezumi - IKEDA Soji, E<lt>hatuka@nezumi.nuE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 by Hatuka*nezumi - IKEDA Soji

This library is free software; you can redistribute it and/or modify it
under the same terms as Perl. For more details, see the full text of
the licenses at <http://dev.perl.org/licenses/>.

This program is distributed in the hope that it will be
useful, but without any warranty; without even the implied
warranty of merchantability or fitness for a particular purpose.

=cut
