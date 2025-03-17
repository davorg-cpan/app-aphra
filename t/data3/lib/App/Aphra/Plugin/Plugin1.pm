package App::Aphra::Plugin::Plugin1;

sub new {
  my $class = shift;
  my %obj = @_;
  return bless \%obj, $class;
}

1;
