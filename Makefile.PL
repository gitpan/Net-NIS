# $Id$
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'Net::NIS',
    AUTHOR        => 'Eduardo Santiago <esm@cpan.org>',
    VERSION_FROM  => 'NIS.pm',
    ABSTRACT_FROM => 'NIS.pod',
    LIBS          => '-lnsl',
    PREREQ_PM     => { 'Test::More' => 0 },

    # The PREOP condition prevents me from doing incomplete releases :-)
    dist          => {
        COMPRESS => 'gzip -9f',
        SUFFIX   => 'gz',
        PREOP    => 'fgrep  \?\? Changes && exit 1 || true',
    },

);
