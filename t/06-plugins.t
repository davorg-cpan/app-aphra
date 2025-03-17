use strict;
use warnings;

use FindBin '$Bin';
use lib 'lib';

use Test::More;
use App::Aphra;

# Easy way to bail out if the pandoc executable isn't installed
use Pandoc;
plan skip_all => "pandoc isn't installed; this module won't work"
  unless pandoc;

chdir("$Bin/data3");

@ARGV = ('build');

my $app = App::Aphra->new;
$app->site_vars;
ok(my $p = $app->plugins, 'We have plugins');

diag $_ for keys %$p;

done_testing;
