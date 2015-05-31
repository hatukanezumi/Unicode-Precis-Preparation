#-*- perl -*-
#-*- coding: utf-8 -*-

use strict;
use warnings;
use Test::More tests => 10;

use Unicode::Precis::Preparation qw(:all);

# VIRAMA ZWNJ
ok(prepare("\x{094D}\x{200C}"));
ok(prepare("\x{094D}\x{200C}" => IdentifierClass));
is_deeply([prepare("\x{094D}\x{200C}" => IdentifierClass)],
    [result => PVALID]);
# ZWNJ
ok(prepare("\x{200C}"));
ok(!prepare("\x{200C}" => IdentifierClass));
is_deeply([prepare("\xE2\x80\x8C" => IdentifierClass)],
    [result => CONTEXTJ, offset => 0, length => 3, ord => 0x200C]);
is_deeply([prepare("\x{200C}" => IdentifierClass)],
    [result => CONTEXTJ, offset => 0, length => 1, ord => 0x200C]);
ok(!prepare("\x{0620}\x{200C}\x{094D}" => IdentifierClass));
is_deeply(
    [prepare("\xD8\xA0\xE2\x80\x8C\xE0\xA5\x8D" => IdentifierClass)],
    [result => CONTEXTJ, offset => 2, length => 3, ord => 0x200C]
);
is_deeply(
    [prepare("\x{0620}\x{200C}\x{094D}" => IdentifierClass)],
    [result => CONTEXTJ, offset => 1, length => 1, ord => 0x200C]
);
