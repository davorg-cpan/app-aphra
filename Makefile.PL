use ExtUtils::MakeMaker;

WriteMakefile(
  NAME         => 'App::Aphra',
  VERSION_FROM => 'lib/App/Aphra.pm',
  LICENSE      => 'perl_5',

  EXE_FILES    => [ 'bin/aphra' ],

  PREREQ_PM    => {
    Clone    => 0,
    Template => 0,
    Moose    => 0,
    'Template::Provider::Pandoc' => 0,
  },

  META_MERGE    => {
    'meta-spec' => { version => 2 },
    resources => {
      repository => {
        type => 'git',
        url  => 'https://github.com/davorg/app-aphra.git',
        web  => 'https://github.com/davorg/app-aphra',
      },
    },
  }
);
