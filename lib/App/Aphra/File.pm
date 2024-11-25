package App::Aphra::File;

use Moose;
use Carp;
use File::Basename;
use File::Path 'make_path';
use File::Copy;
use Text::FrontMatter::YAML;
use Path::Tiny ();
use URI;

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

  my %args = ref $_[0] ? %{$_[0]} : @_;

  croak "No app attribute\n" unless $args{app};
  if ($args{filename}) {
    debug("Got $args{filename}");
    my @exts = keys %{ $args{app}->config->{extensions}};
    my ($name, $path, $ext) = fileparse($args{filename}, @exts);
    chop($path) if $name;
    chop($name) if $ext;
    @args{qw[path name extension]} = ($path, $name, $ext);
  }

  return $class->$orig(\%args);
};

sub is_template {
  my $self = shift;

  return scalar grep { $_ eq $self->extension }
    keys %{$self->app->config->{extensions}};
}

sub destination_dir {
  my $self = shift;

  my $dir = $self->path;

  my $src = $self->app->config->{source};
  my $tgt = $self->app->config->{target};

  $dir =~ s/^$src/$tgt/;

  return $dir;
}

sub template_name {
  my $self = shift;

  my $src = $self->app->config->{source};
  my $template_name = $self->full_name;
  $template_name =~ s|^$src/||;

  return $template_name;
}

sub output_name {
  my $self = shift;

  my $output = $self->template_name;
  my $ext    = '\.' . $self->extension;
  $output =~ s/$ext$//;

  return $output;
}

sub full_name {
  my $self = shift;

  my $full_name = $self->path . '/' . $self->name;
  $full_name .= '.' . $self->extension if $self->extension;
  return $full_name;
}

sub uri {
  my $self = shift;

  my $uri = $self->app->uri;
  my $base = $self->app->site_vars->{base};
  my $path = $self->output_name;
  $path =~ s/^$base//;
  $uri .= $path;
  $uri =~ s/index\.html$//;
  
  return URI->new($uri);
}

sub process {
  my $self = shift;

  debug('File is: ', $self->full_name);

  my $dest = $self->destination_dir;
  debug("Dest: $dest");

  make_path $dest;

  if ($self->is_template) {
    debug("It's a template");

    my $template = $self->template_name;
    my $out      = $self->output_name;

    debug("tt: $template -> $out");

    my $template_text = Path::Tiny::path($self->full_name)->slurp_utf8;
    my $front_matter = Text::FrontMatter::YAML->new(
      document_string => $template_text,
    );

    my $front_matter_hashref = $front_matter->frontmatter_hashref // {};
    my $template_data = $front_matter->data_text;
    my $orig_layout;
    if ($front_matter_hashref->{layout}) {
      $orig_layout = $self->app->template->{SERVICE}{WRAPPER};
      $self->app->template->{SERVICE}{WRAPPER} = [ $front_matter_hashref->{layout} ];
    }

    $self->app->template->process(\$template_data, {
      page => $front_matter_hashref,
      file => $self,
    }, $out)
      or croak $self->app->template->error;

    $orig_layout and $self->app->template->{SERVICE}{WRAPPER} = $orig_layout;
  } else {
    my $file = $self->full_name;
    debug("Copy: $file -> ", $self->destination_dir);
    copy $file, $self->destination_dir;
  }
}

sub debug {
  carp @_ if $ENV{APHRA_DEBUG};
}

__PACKAGE__->meta->make_immutable;

1;
