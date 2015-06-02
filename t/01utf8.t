#-*- perl -*-
#-*- coding: utf-8 -*-

use strict;
use warnings;
use Encode qw(encode_utf8 _utf8_on);
use Test::More tests => 1 + 132 + 4096;

use Unicode::Precis::Preparation qw(:all);

ok(prepare(""));

# Non-shortest form
#ToDo

# Incomplete
#ToDo

# Disallowed (noncharacters) (66)
my @NONCHARACTERS = (
    0xFDD0 .. 0xFDEF,
    map { (($_ * 0x10000) ^ 0xFFFE, ($_ * 0x10000) ^ 0xFFFF) } (0 .. 0x10)
);
foreach my $cp (@NONCHARACTERS) {
    my $uc = chr $cp;
    _utf8_on($uc);
    ok(!prepare($uc), sprintf 'Noncharacter U+%04X', $cp);
    $uc = encode_utf8($uc);
    ok(!prepare($uc), sprintf 'Noncharacter \\x%*v02X', '\\x', $uc);
}

# Disallowed (surrogates) (2048)
my @SURROGATES = (0xD800 .. 0xDFFF);
foreach my $cp (@SURROGATES) {
    my $uc = chr $cp;
    _utf8_on($uc);
    ok(!prepare($uc), sprintf 'Surrogate U+%04X', $cp);
    $uc = encode_utf8($uc);
    ok(!prepare($uc), sprintf 'Surrogate \\x%*v02X', '\\x', $uc);
}
