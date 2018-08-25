use strict;
use warnings;

use FindBin '$Bin';

use Test::More;
use App::Aphra;

chdir("$Bin/data");

@ARGV = ('build');

my $outfile = 'docs/index.html';

unlink $outfile if -r $outfile;

App::Aphra->new->run;

ok(-e $outfile, 'Got an output file');
ok(-f $outfile, "... and it's a real file");

open my $out_fh, '<', $outfile or die $!;
my $contents = do { local $/; <$out_fh> };
my $exp_contents = qq[<h1 id="test">Test</h1>\n];

ok($contents, 'Got some contents');
is($contents, $exp_contents, 'Got the correct contents');

unlink $outfile if -r $outfile;

done_testing;
