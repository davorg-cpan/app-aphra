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

has config => (
  isa => 'HashRef',
  is  => 'ro',
  lazy_build => 1,
);

sub _build_config {
  return {
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

  find({ wanted => $self->make_do_this, no_chdir => 1 }, 'in');
}

sub make_do_this {
  my $self = shift;
  my $tt   = $self->template;

  return sub {
    debug("File is: $_\n");
    return unless -f;
    debug("File::Find::dir: $File::Find::dir\n");
    my $dest = $File::Find::dir =~ s|^in/?||r;
    debug("Dest: $dest\n");

    debug("docs/$dest");
    make_path "docs/$dest";

    if (/\.tt$/) {
      my $out = s|\.tt$||r;
      $out =~ s|^in/||;

      debug("tt: $_ -> $out\n");
      $tt->process($_, {}, $out)
        or die $tt->error;
    } else {
      debug("Copy: $_ -> docs/$dest\n");
      copy $_, "docs/$dest";
    }
  };
}

sub debug {
  warn @_ if $ENV{TT_DEBUG};
}

1;
