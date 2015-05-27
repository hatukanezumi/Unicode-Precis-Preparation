#-*- perl -*-
#-*- coding: utf-8 -*-

package Unicode::Precis::Preparation;

use 5.008001;
use strict;
use warnings;

use base qw(Exporter);

our %EXPORT_TAGS =
    ('all' => [qw(prepare)], 'internal' => [qw(_lookup_prop _lookup_ctx)]);
our @EXPORT_OK = (@{$EXPORT_TAGS{'all'}});

our $VERSION = '0.000_01';
#XXX$VERSION = eval $VERSION;  # see L<perlmodstyle>

require XSLoader;
XSLoader::load('Unicode::Precis::Preparation', $VERSION);

1;
__END__

=encoding utf-8

=head1 NAME

Unicode::Precis::Preparation - RFC 7564 PRECIS Framework - Preparation

=head1 SYNOPSIS

  use Unicode::Precis::Preparation qw(prepare);
  $result = prepare($string, 'IdentifierClass');

=head1 DESCRIPTION

L<Unicode::Precis::Preparation> prepares Unicode string or UTF-8 bytestring
according to PRECIS framework.

=head2 Function

=over

=item prepare ( $string, [ $stringclass ] )

Check if a string conforms to specified string class.

Parameters:

=over

=item $string

A string to be checked, Unicode string or bytestring.

Note that bytestring won't be upgraded to Unicode string and it will be
treated as UTF-8 sequence.

=item $stringclass

C<"ValidUTF8"> (default), C<"IdentifierClass"> or C<"FreeFormClass">.

=back

Returns:

True value if the string conforms to specified string class.
Otherwise false value.

=back

=head2 EXPORT

None are exported by default.
prepare() may be exported by C<:all> tag.

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
