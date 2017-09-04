package App::Aphra::File;

use Moose;
use Carp;
use File::Basename;

has [qw[path name extension ]] => (
  isa => 'Str',
  is  => 'ro',
);

has app => (
  isa => 'App::Aphra',
  is  => 'ro',
);

around BUILDARGS => sub {
  my $orig = shift;
  my $class = shift;
  if (@_ == 1 and not ref $_[0]) {
    croak;
  }

use Data::Dumper;

  my %args = ref $_[0] ? %{$_[0]} : @_;

  croak "No app attribute\n" unless $args{app};
  if ($args{filename}) {
    my @exts = values %{ $args{app}->config->{extensions}};
    my ($name, $path, $ext) = fileparse($args{filename}, @exts);
warn("$path // $name // $ext");
    chop($name, $path);
warn("$path // $name // $ext");
    @args{qw[path name extension]} = ($path, $name, $ext);
  }

  return $class->$orig(\%args);
};

sub is_template {
  my $self = shift;

  return scalar grep { $_ eq $self->extension }
    values %{$self->app->config->{extensions}};
}

1;
