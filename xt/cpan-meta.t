use v5.14;
use warnings;

use Test::More;
use CPAN::Meta;

plan skip_all => 'author test'
  unless $ENV{AUTHOR_TESTING};

for my $file (qw(META.json MYMETA.json META.yml MYMETA.yml)) {
  next unless -e $file;

  my $meta = eval { CPAN::Meta->load_file($file) };
  ok(!$@, "$file parsed by CPAN::Meta")
    or diag($@);

  ok($meta, "$file loaded");
}
done_testing;

