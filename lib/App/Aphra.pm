package App::Aphra;

use strict;
use warnings;

use Moose;
use Template;
use Template::Provider::Markdown::Pandoc;
use FindBin '$Bin';
use File::Find;
use File::Path 'make_path';
use File::Copy;
use Getopt::Long;

has commands => (
  isa => 'HashRef',
  is => 'ro',
  default => sub { {
    build => \&build,
  } },
);

has config_defaults => (
  isa => 'HashRef',
  is  => 'ro',
  lazy_build => 1,
);

sub _build_config_defaults {
  return {
    source    => 'in',
    fragments => 'fragments',
    layouts   => 'layouts',
    target    => 'docs',
  };
}

has config => (
  isa => 'HashRef',
  is  => 'ro',
  lazy_build => 1,
);

sub _build_config {
  my $self = shift;

  my %opts;
  GetOptions(\%opts, 'source:s', 'fragments:s', 'layouts:s', 'target:s');

  my %defaults = %{ $self->config_defaults };

  my %config;
  for (qw[source fragments layouts target]) {
    $config{$_} = $opts{$_} // $defaults{$_};
  }
  return \%config;
}

has pandoc => (
  isa => 'Pandoc',
  is  => 'ro',
  lazy_build => 1,
);

sub _build_pandoc {
  return Pandoc->new;
}

has include_path => (
  isa => 'ArrayRef',
  is  => 'ro',
  lazy_build => 1,
);

sub _build_include_path {
  my $self = shift;

  my $include_path;
  foreach (qw[source fragments layouts]) {
    push @$include_path, $self->config->{$_}
      if exists $self->config->{$_};
  }

  return $include_path;
}

has template => (
  isa => 'Template',
  is  => 'ro',
  lazy_build => 1,
);

sub _build_template {
  my $self = shift;

  return Template->new(
    LOAD_TEMPLATES => [
      Template::Provider::Markdown::Pandoc->new(
        INCLUDE_PATH => $self->include_path
      ),
    ],
    INCLUDE_PATH => $self->include_path,
    OUTPUT_PATH  => $self->config->{target},
    WRAPPER      => 'page',
  );
}

sub run {
  my $self = shift;

  @ARGV or die "Must give a command\n";

  my $cmd = shift @ARGV;

  if (my $method = $self->commands->{$cmd}) {
    $self->$method;
  } else {
    die "$cmd is not a valid command\n";
  }
}

sub build {
  my $self = shift;

  my $src = $self->config->{source};

  -e $src or die "Cannot find $src\n";
  -d $src or die "$src is not a directory\n";

  find({ wanted => $self->make_do_this, no_chdir => 1 },
       $self->config->{source});
}

sub make_do_this {
  my $self = shift;

  return sub {
    debug("File is: $_\n");
    return unless -f;
    my $src = $self->config->{source};
    debug("File::Find::dir: $File::Find::dir\n");
    my $dest = $File::Find::dir =~ s|^$src/?||r;
    debug("Dest: $dest\n");

    debug("docs/$dest");
    make_path "docs/$dest";

    if (/\.tt$/ or /\.md$/) {
      # The template name needs to be relative to one of the paths
      # in INCLUDE_PATH. So we need to remove $src from the start.

      my $template = s|^$src/||r;

      # The output file need the ".tt" removed from the end.
      my $out = $template =~ s|\.tt$||r;

      debug("tt: $template -> $out\n");
      $self->template->process($template, {}, $out)
        or die $self->template->error;
    } else {
      debug("Copy: $_ -> docs/$dest\n");
      copy $_, "docs/$dest";
    }
  };
}

sub debug {
  warn @_ if $ENV{UTTERSON_DEBUG};
}

1;
