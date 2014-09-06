use strict;
use Test::More 0.98;

use_ok $_ for qw(
    File::DirDiff
);

ok !system "$^X -wc bin/dirdiff";

done_testing;

