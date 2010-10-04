use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Games::Killingfloor::Mapcache',
    'VERSION_FROM'	=> 'Mapcache.pm', # finds $VERSION
    'PREREQ_PM'		=> {Win32::Registry => 0.10}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ? (
      ABSTRACT_FROM => 'Mapcache.pm', 
      AUTHOR     => 'Stefan Gipper <stefanos@cpan.org>',
    ) : ()),
);