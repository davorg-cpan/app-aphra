package Template::Provider::Markdown::Pandoc;

use strict;
use warnings;
use parent 'Template::Provider';
use Pandoc;

my $pandoc;

sub new {
  my $class = shift;
  my %opts  = @_;

  my $ext = delete $opts{EXTENSION};

  my $self = $class->SUPER::new(%opts);

  $self->{extension} = $ext;

  return bless $self, $class;
}

sub _template_content {
  my $self = shift;
  my ($path) = @_;

  my ($data, $error, $mod_date) = $self->SUPER::_template_content($path);

  if (! $self->{extension} or $path =~ /\.$self->{extension}$/) {
    $pandoc //= pandoc;
    $data = $pandoc->convert(markdown => 'html', $data);
  }

  return ($data, $error, $mod_date) if wantarray;
  return $data;
}

1;
