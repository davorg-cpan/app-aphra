package compat::perl5;

# This helps hint to perl 7+ what level of compatibility this code has with future versions of perl.
# use compat::perl5 should be the first thing in your code. Especially before use strict, warnings, v5.XXX, or feature.

BEGIN {
    $] <= 8 or die("This code is incompatible with Perl 8. Please see XXX for more information.");
    if ( $] > 6 ) {
        warn_quietly_once("This code is being run using Perl $]. It should be updated or may break in Perl 8. See YYY for more information.");
    }
}

sub import {

    # no warnings;
    ${^WARNING_BITS} = undef;

    # perl  -e'my $h; BEGIN {  $h = $^H } printf("\$^H = 0x%08X\n", $h); '
    $^H = 0x0;

    %^H = ();
}

1;
