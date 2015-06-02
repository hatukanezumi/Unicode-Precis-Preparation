#-*- perl -*-
#-*- coding: utf-8 -*-

use strict;
use warnings;
use Test::More tests => 29;

use Unicode::Precis::Preparation qw(:all);

# VIRAMA ZWNJ
ok(prepare("\x{094D}\x{200C}"));
ok(prepare("\x{094D}\x{200C}" => IdentifierClass));
is_deeply([prepare("\xE0\xA5\x8D\xE2\x80\x8C" => IdentifierClass)],
    [result => PVALID, offset => 6]);
is_deeply([prepare("\x{094D}\x{200C}" => IdentifierClass)],
    [result => PVALID, offset => 2]);

# sos ZWNJ
ok(prepare("\x{200C}"));
ok(!prepare("\x{200C}" => IdentifierClass));
is_deeply([prepare("\xE2\x80\x8C" => IdentifierClass)],
    [result => CONTEXTJ, offset => 0, length => 3, ord => 0x200C]);
is_deeply([prepare("\x{200C}" => IdentifierClass)],
    [result => CONTEXTJ, offset => 0, length => 1, ord => 0x200C]);

# JT_D ZWNJ other
ok(!prepare("\x{0628}\x{200C}\x6C" => IdentifierClass));
is_deeply(
    [prepare("\xD8\xA8\xE2\x80\x8C\x6C" => IdentifierClass)],
    [result => CONTEXTJ, offset => 2, length => 3, ord => 0x200C]
);
is_deeply(
    [prepare("\x{0628}\x{200C}\x6C" => IdentifierClass)],
    [result => CONTEXTJ, offset => 1, length => 1, ord => 0x200C]
);

# JT_D ZWNJ ZWNJ
ok(!prepare("\x{0628}\x{200C}\x{200C}" => IdentifierClass));
is_deeply(
    [prepare("\xD8\xA8\xE2\x80\x8C\xE2\x80\x8C" => IdentifierClass)],
    [result => CONTEXTJ, offset => 2, length => 3, ord => 0x200C]
);
is_deeply(
    [prepare("\x{0628}\x{200C}\x{200C}" => IdentifierClass)],
    [result => CONTEXTJ, offset => 1, length => 1, ord => 0x200C]
);

# JT_D ZWNJ eos
ok(!prepare("\x{0628}\x{200C}" => IdentifierClass));
is_deeply(
    [prepare("\xD8\xA8\xE2\x80\x8C" => IdentifierClass)],
    [result => CONTEXTJ, offset => 2, length => 3, ord => 0x200C]
);
is_deeply([prepare("\x{0628}\x{200C}" => IdentifierClass)],
    [result => CONTEXTJ, offset => 1, length => 1, ord => 0x200C]);

# JT_D ZWNJ JT_D ZWNJ eos
ok(!prepare("\x{0628}\x{200C}\x{0628}\x{200C}" => IdentifierClass));
is_deeply(
    [prepare("\xD8\xA8\xE2\x80\x8C\xD8\xA8\xE2\x80\x8C" => IdentifierClass)],
    [result => CONTEXTJ, offset => 7, length => 3, ord => 0x200C]
);
is_deeply(
    [prepare("\x{0628}\x{200C}\x{0628}\x{200C}" => IdentifierClass)],
    [result => CONTEXTJ, offset => 3, length => 1, ord => 0x200C]
);

# JT_D ZWNJ JT_D ZWNJ JT_D
ok(prepare("\x{0628}\x{200C}\x{0628}\x{200C}\x{0628}" => IdentifierClass));
is_deeply(
    [   prepare(
            "\xD8\xA8\xE2\x80\x8C\xD8\xA8\xE2\x80\x8C\xD8\xA8" =>
                IdentifierClass
        )
    ],
    [result => PVALID, offset => 12]
);
is_deeply(
    [prepare("\x{0628}\x{200C}\x{0628}\x{200C}\x{0628}" => IdentifierClass)],
    [result => PVALID, offset => 5]
);

# JT_D ZWNJ JT_R
ok(prepare("\x{0628}\x{200C}\x{0627}" => IdentifierClass));
is_deeply([prepare("\xD8\xA8\xE2\x80\x8C\xD8\xA7" => IdentifierClass)],
    [result => PVALID, offset => 7]);
is_deeply([prepare("\x{0628}\x{200C}\x{0627}" => IdentifierClass)],
    [result => PVALID, offset => 3]);

# JT_D ZWNJ JT_T JT_R
ok(prepare("\x{0628}\x{200C}\x{0652}\x{0627}" => IdentifierClass));
is_deeply([prepare("\xD8\xA8\xE2\x80\x8C\xD9\x92\xD8\xA7" => IdentifierClass)],
    [result => PVALID, offset => 9]);
is_deeply([prepare("\x{0628}\x{200C}\x{0652}\x{0627}" => IdentifierClass)],
    [result => PVALID, offset => 4]);

