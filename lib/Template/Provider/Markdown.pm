package Template::Provider::Markdown;

use strict;
use warnings;
use parent 'Template::Provider';
use Pandoc;

my $pandoc;

sub _template_content {
  my $self = shift;
  my ($path) = @_;

  my ($data, $error, $mod_date) = $self->SUPER::_template_content($path);

  if ($path =~ /\.md$/) {
    $data = pandoc->convert(markdown => 'html', $data);
  }

  return ($data, $error, $mod_date) if wantarray;
  return $data;
}

1;
