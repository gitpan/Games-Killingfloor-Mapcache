package Games::Killingfloor::Mapcache;
#use strict;
#use warnings;
use Exporter;
our @ISA = qw/Exporter/;
our @EXPORT = qw/nextmap/;
our $VERSION = '0.3';

use Win32::OLE qw( in );
#use Win32::Registry;#old
use Win32::TieRegistry (
	Delimiter   => "/",
	ArrayValues => 1,
	TiedRef     => \$reg
);

sub nextmap {
	my $registry;
	unless($ARGV[0]){
		my $WMI = Win32::OLE->GetObject("winmgmts:{impersonationLevel=impersonate}\\\\.\\Root\\cimv2");
		foreach $Proc ( sort {lc $a->{ProcessId} cmp lc $b->{ProcessId}} in( $WMI->InstancesOf( "Win32_Process" ) ) ){
			if($Proc->{ExecutablePath} =~ /steam.exe$/i){
				$registry = $Proc->{ExecutablePath};
				$registry =~ s/\\/\//g;
				$registry =~ s/\/Steam.exe$//i;
				last;
			}
		}

		use Win32::TieRegistry (
			Delimiter   => "/",
			ArrayValues => 1,
			TiedRef     => \$reg
		);

		#"Classes" for HKEY_CLASSES_ROOT
		#"CUser" for HKEY_CURRENT_USER
		#"LMachine" for HKEY_LOCAL_MACHINE
		#"Users" for HKEY_USERS
		#"PerfData" for HKEY_PERFORMANCE_DATA
		#"CConfig" for HKEY_CURRENT_CONFIG
		#"DynData" for HKEY_DYN_DATA

		unless($registry){
			foreach (
				"Classes/Applications/steam.exe/shell/open/command",
				"LMachine/SOFTWARE/Classes/steam/Shell/Open/Command",
				"LMachine/SOFTWARE/Classes/Applications/steam.exe/shell/open/command",
				"Classes/steam/Shell/Open/Command"
				){
				if(my $more = $reg->{$_}){
					if($more->{'/'}[0]){
						if($more->{'/'}[0] =~ /^"([^"]*)"/){
							$registry = $1;
							$registry =~ s/\\/\//g;
							$registry =~ s/\/Steam.exe$//i;
						}else{
							$registry = $more->{'/'}[0];
							$registry =~ s/\\/\//g;
							$registry =~ s/\/Steam.exe$//i;
						}
						last;
					}
				}
			}
		}
		if($registry !~ /\/$/){
			$registry .= '/steamapps/common/killingfloor';
		}else{
			$registry .= 'steamapps/common/killingfloor';
		}
	}

	my $steampfad = $ARGV[0] || $registry || ".";

	if(!-e("$steampfad\\Cache\\cache.ini")){
		print "Keine cache.ini gefunden! ($steampfad)\n";
		exit;
	}
	print "\t\n";
	print "\tSteam erkannt: $steampfad\n";

	my $notcache;
	my $found = 0;
	my $foundwrite = 0;
	open(F,"<$steampfad/Cache/cache.ini");
	while(<F>){
		s/[\n\r]//g;
		my($key,$datei) = split(/=/,$_,2);
		next if(!$key or !$datei);
		$found++;

		if($datei =~ /\.rom$/i){
			$notcache = "Maps";
		}elsif($datei =~ /\.u$/i){
			$notcache = "System";
		}elsif($datei =~ /\.ogg$/i){
			$notcache = "Music";
		}elsif($datei =~ /\.uax$/i){
			$notcache = "Sounds";
		}elsif($datei =~ /\.utx$/i){
			$notcache = "Textures";
		}elsif($datei =~ /\.ukx$/i){
			$notcache = "Animations";
		}elsif($datei =~ /\.usx$/i){
			$notcache = "StaticMeshes";
		}

		if(!-e("$steampfad\\$notcache\\$datei") && -s("$steampfad\\Cache\\$key.uxx")){
			print "\tDatei $key einlesen: $datei\n";
			open(R,"<$steampfad\\Cache\\$key.uxx");
			binmode(R);
			my @temp = <R>;
			close(R);

			print "\tDatei $key speichern: $datei\n";
			open(W,">$steampfad\\$notcache\\$datei");
			binmode(W);
			print W @temp;
			close(W);
			$foundwrite++;
		}
		unlink("$steampfad/Cache/$key.uxx");
	}
	close(F);

	open(F,">$steampfad/Cache/cache.ini");
	print F '[Cache]'."\n";
	close(F);

	print "\tStatistik: $foundwrite von $found Dateien verwendet.\n";
	sleep(2);
	return;
}


=pod

=head1 NAME

Games::Killingfloor::Mapcache - convert Maps as Cache in regular Maps

=head1 SYNOPSIS

	use Games::Killingfloor::Mapcache;
	nextmap();

=head1 DESCRIPTION

Games::Killingfloor::Mapcache convert Maps as Cache in regular Maps

=head1 AUTHOR

    Stefan Gipper <stefanos@cpan.org>, http://www.coder-world.de/

=head1 COPYRIGHT

Games::Killingfloor::Mapcache is Copyright (c) 2011 Stefan Gipper
All rights reserved.

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

=head1 SEE ALSO



=cut
