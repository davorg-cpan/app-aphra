use v5.14;
use warnings;

use Test::More;
use CPAN::Meta;
use Module::Metadata;
use ExtUtils::Manifest qw(maniread);

plan skip_all => 'author test'
  unless $ENV{AUTHOR_TESTING};

my $meta_file =
     -e 'MYMETA.json' ? 'MYMETA.json'
   : -e 'META.json'   ? 'META.json'
   : -e 'MYMETA.yml'  ? 'MYMETA.yml'
   : -e 'META.yml'    ? 'META.yml'
   : undef;

plan skip_all => 'No META/MYMETA file found'
  unless $meta_file;

my $meta = CPAN::Meta->load_file($meta_file);
my $dist_version = $meta->version;

my $manifest = maniread();
my @modules  = sort grep { m{^lib/.*\.pm$} } keys %$manifest;

for my $file (@modules) {
  my $info = Module::Metadata->new_from_file($file);
  ok($info, "$file parsed by Module::Metadata");

  my $version = $info ? $info->version : undef;
  ok(defined $version, "$file has statically detectable version")
    or diag("$file => version undef");

  is($info->version, $dist_version, "$file version matches dist version");
}

done_testing;

