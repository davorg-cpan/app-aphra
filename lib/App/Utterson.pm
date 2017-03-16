package App::Utterson;

use strict;
use warnings;

use Moose;
use Template;
use Pandoc ();
use FindBin '$Bin';
use File::Find;
use File::Path 'make_path';
use File::Copy;

has commands => (
  isa => 'HashRef',
  is  => 'ro',
  default => sub { {
    build => \&build,
  } },
);

has config => (
  isa => 'HashRef',
  is  => 'ro',
  lazy_build => 1,
);

sub _build_config {
  return {
    source       => 'in',
    include_path => ["$Bin/../tt_lib", "$Bin/.." ],
    output_path  => "$Bin/../docs",
  };
}

has pandoc => (
  isa => 'Pandoc',
  is  => 'ro',
  lazy_build => 1,
);

sub _build_pandoc {
  return Pandoc->new;
}

has template => (
  isa => 'Template',
  is  => 'ro',
  lazy_build => 1,
);

sub _build_template {
  my $self = shift;

  return Template->new(
    INCLUDE_PATH => $self->config->{include_path},
    OUTPUT_PATH  => $self->config->{output_path},
    WRAPPER      => 'page',
    FILTERS      => {
      markdown   => sub { $self->pandoc->convert(markdown => 'html', $_[0]) },
    },
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

    if (/\.tt$/) {
      my $out = s|\.tt$||r;
      $out =~ s|^$src/||;

      debug("tt: $_ -> $out\n");
      $self->template->process($_, {}, $out)
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
