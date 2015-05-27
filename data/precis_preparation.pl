#! perl

use strict;
use warnings;

use constant PROP_BLKWIDTH => 6;
use constant CTX_BLKWIDTH => 7;

my $precis_table  = shift;
my $UnicodeData   = shift;
my $ArabicShaping = shift;
my $Scripts       = shift;

my ($prop_index, $prop_array) = build_prop_map();
my ($ctx_index, $ctx_array) = build_ctx_map();

printf do { local @ARGV = qw(precis_preparation.c.in); local $/; <> },
    $prop_index, $prop_array, PROP_BLKWIDTH(), PROP_BLKWIDTH(),
    $ctx_index, $ctx_array, CTX_BLKWIDTH(), CTX_BLKWIDTH();


sub build_prop_map {

my @PROPS = ();
my $fh;

open $fh, '<', $precis_table or die $!;

$_ = <$fh>;
chomp $_;
my @fields = split /,/, $_;
die unless @fields;

while (<$fh>) {
    chomp $_;
    @_ = split /,/, $_;
    my %fields = map { (lc $_ => shift @_) } @fields;

    my ($begin, $end) = split /-/, $fields{codepoint}, 2;
    $end ||= $begin;

    my $property = $fields{property};
    $property =~ s/\A(ID_DIS) or FREE_PVAL\z/$1/;

    foreach my $c (hex("0x$begin") .. hex("0x$end")) {
        next unless $c < 0x40000;
        $PROPS[$c] = $property;
    }
}
close $fh;

## Debug
#for (my $c = 0; $c < 0x040000; $c++) {
#    next unless defined $PROPS[$c];
#    printf STDERR "%04X\t%s\n", $c, $PROPS[$c];
#}

# Construct compact array.

my $blklen = 1 << PROP_BLKWIDTH();

my @C_ARY = ();
my @C_IDX = ();
for (my $idx = 0; $idx < 0x40000; $idx += $blklen) {
    my @BLK = ();
    for (my $bi = 0; $bi < $blklen; $bi++) {
        my $c = $idx + $bi;
        $BLK[$bi] = $PROPS[$c];
    }
    my ($ci, $bi) = (0, 0);
C_ARY:
    for ($ci = 0; $ci <= $#C_ARY; $ci++) {
        for ($bi = 0; $bi < $blklen; $bi++) {
            last C_ARY if $#C_ARY < $ci + $bi;
            last unless $BLK[$bi] eq $C_ARY[$ci + $bi];
        }
        last C_ARY if $bi == $blklen;
    }
    push @C_IDX, $ci;
    if ($bi < $blklen) {
        for (; $bi < $blklen; $bi++) {
            push @C_ARY, $BLK[$bi];
        }
    }
    printf STDERR "U+%04X..U+%04X: %d..%d / %d      \r", $idx,
        $idx + ($blklen) - 1, $ci, $ci + ($blklen) - 1, scalar @C_ARY;
}
print STDERR "\n";

# Build compact array index.

my $index = '';
my $line  = '';
foreach my $ci (@C_IDX) {
    if (74 < 4 + length($line) + length(", $ci")) {
        $index .= ",\n" if length $index;
        $index .= "    $line";
        $line = '';
    }
    $line .= ", " if length $line;
    $line .= "$ci";
}
$index .= ",\n" if length $index;
$index .= "    $line";

# Build compact array.

my $array = '';
$line = '';
foreach my $b (@C_ARY) {
    die "property unknown\n" unless defined $b;
    my $citem = 'PRECIS_' . $b;
    if (74 < 4 + length($line) + length(", $citem")) {
        $array .= ",\n" if length $array;
        $array .= "    $line";
        $line = '';
    }
    $line .= ", " if length $line;
    $line .= $citem;
}
$array .= ",\n" if length $array;
$array .= "    $line";

# Statistics.

printf STDERR
    "%d codepoints (in BMP, SMP, SIP and TIP), %d entries\n",
    scalar(grep $_, @PROPS), scalar(@C_ARY);
die "Too many entries to work with unsigned 16-bit short integer: "
    . scalar(@C_ARY) . "\n"
    if (1 << 16) <= scalar(@C_ARY);
warn "Too many entries to work with signed 16-bit pointer: "
    . scalar(@C_ARY) . "\n"
    if (1 << 15) <= scalar(@C_ARY);

    return ($index, $array);
}

sub build_ctx_map {
   no warnings;

my @PROPS = ();
my $fh;

open $fh, '<', $UnicodeData or die $!;
while (<$fh>) {
    chomp $_;
    @_ = split /;/, $_;

    my ($begin, $end) = split /\.\./, $_[0], 2;
    $end ||= $begin;

    my $property = $_[3];

    foreach my $c (hex("0x$begin") .. hex("0x$end")) {
        next unless $c < 0x40000;
        next unless defined $property and $property eq '9';

        die sprintf "Duplicated: U+%04X = %s : CCC_VIRAMA", $c, $PROPS[$c]
            if defined $PROPS[$c];
        $PROPS[$c] = "CCC_VIRAMA";
    }
}
close $fh;

open $fh, '<', $ArabicShaping or die $!;
while (<$fh>) {
    chomp $_;
    @_ = split /; /, $_;

    my ($begin, $end) = split /\.\./, $_[0], 2;
    $end ||= $begin;

    my $property = $_[2];

    foreach my $c (hex("0x$begin") .. hex("0x$end")) {
        next unless $c < 0x40000;
        next unless defined $property and $property =~ /\A[DLTR]\z/;

        die sprintf "Duplicated: U+%04X = %s : JT_%s", $c, $PROPS[$c],
            $property
            if defined $PROPS[$c];
        $PROPS[$c] = "JT_$property";
    }

}
close $fh;

open $fh, '<', $Scripts or die $!;
while (<$fh>) {
    chomp $_;
    s/\s+#.*$//;
    @_ = split /\s*;\s*/, $_;

    my ($begin, $end) = split /\.\./, $_[0], 2;
    $end ||= $begin;

    my $property = $_[1];

    foreach my $c (hex("0x$begin") .. hex("0x$end")) {
        next unless $c < 0x40000;
        next
            unless defined $property
                and $property =~ /\A(Greek|Han|Hebrew|Hiragana|Katakana)\z/;

        die sprintf "Duplicated: U+%04X = %s : SC_%s", $c, $PROPS[$c],
            $property
            if defined $PROPS[$c];
        $PROPS[$c] = "SC_$property";
    }

}
close $fh;

# Construct compact array.

my $blklen = 1 << CTX_BLKWIDTH();

my @C_ARY = ();
my @C_IDX = ();
for (my $idx = 0; $idx < 0x40000; $idx += $blklen) {
    my @BLK = ();
    for (my $bi = 0; $bi < $blklen; $bi++) {
        my $c = $idx + $bi;
        $BLK[$bi] = $PROPS[$c];
    }
    my ($ci, $bi) = (0, 0);
C_ARY:
    for ($ci = 0; $ci <= $#C_ARY; $ci++) {
        for ($bi = 0; $bi < $blklen; $bi++) {
            last C_ARY if $#C_ARY < $ci + $bi;
            last unless $BLK[$bi] eq $C_ARY[$ci + $bi];
        }
        last C_ARY if $bi == $blklen;
    }
    push @C_IDX, $ci;
    if ($bi < $blklen) {
        for (; $bi < $blklen; $bi++) {
            push @C_ARY, $BLK[$bi];
        }
    }
    printf STDERR "U+%04X..U+%04X: %d..%d / %d      \r", $idx,
        $idx + ($blklen) - 1, $ci, $ci + ($blklen) - 1, scalar @C_ARY;
}
print STDERR "\n";

# Build compact array index.

my $index = '';
my $line  = '';
foreach my $ci (@C_IDX) {
    if (74 < 4 + length($line) + length(", $ci")) {
        $index .= ",\n" if length $index;
        $index .= "    $line";
        $line = '';
    }
    $line .= ", " if length $line;
    $line .= "$ci";
}
$index .= ",\n" if length $index;
$index .= "    $line";

# Build compact array.

my $array = '';
$line = '';
foreach my $b (@C_ARY) {
    #die "property unknown\n" unless defined $b;
    my $citem;
    unless (defined $b) {
        $citem = '0';
    } else {
        $citem = $b;
    }
    if (74 < 4 + length($line) + length(", $citem")) {
        $array .= ",\n" if length $array;
        $array .= "    $line";
        $line = '';
    }
    $line .= ", " if length $line;
    $line .= $citem;
}
$array .= ",\n" if length $array;
$array .= "    $line";

# Statistics.

printf STDERR
    "%d codepoints (in BMP, SMP, SIP and TIP), %d entries\n",
    scalar(grep $_, @PROPS), scalar(@C_ARY);
die "Too many entries to work with unsigned 16-bit short integer: "
    . scalar(@C_ARY) . "\n"
    if (1 << 16) <= scalar(@C_ARY);
warn "Too many entries to work with signed 16-bit pointer: "
    . scalar(@C_ARY) . "\n"
    if (1 << 15) <= scalar(@C_ARY);

    return ($index, $array);
}
