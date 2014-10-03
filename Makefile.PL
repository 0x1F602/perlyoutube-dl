use ExtUtils::MakeMaker;
WriteMakefile(
    NAME            => 'YoutubeDL::Wrapper',
    AUTHOR          => 'Patrik Natali <pat.natali@gmail.com>',
    VERSION_FROM    => 'lib/YoutubeDL/Wrapper.pm',
    ABSTRACT        => 'Perl wrapper for youtube-dl Python program',
    LIB             => './lib'
);
