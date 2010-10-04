package Games::Killingfloor::Mapcache;
use strict;
use warnings;
use Exporter;
our @ISA = qw/Exporter/;
our @EXPORT = qw/nextmap/;
our $VERSION = '0.1';

use Win32::Registry;

sub nextmap {
	my $registry;
	my ($search1,$search2,$search3,$search4);
	unless($ARGV[0]){
		$::HKEY_CLASSES_ROOT->Open("Applications\\steam.exe\\shell\\open\\command", $search1);
		$::HKEY_CLASSES_ROOT->Open("steam\\Shell\\Open\\Command", $search2);
		$::HKEY_LOCAL_MACHINE->Open("SOFTWARE\\Classes\\Applications\\steam.exe\\shell\\open\\command", $search3);
		$::HKEY_LOCAL_MACHINE->Open("SOFTWARE\\Classes\\steam\\Shell\\Open\\Command", $search4);

		$search1->GetValues(\my %values1);
		$search2->GetValues(\my %values2);
		$search3->GetValues(\my %values3);
		$search4->GetValues(\my %values4);
		foreach (sort(keys(%values1))) {
			my($name, $type, $data) = @{$values1{$_}};
			$data =~ s/\"//g;
			if($data =~ /steam.exe/){
				$data = (split(/steam.exe/,$data,2))[0];
				$registry = $data .'steamapps\common\killingfloor';
				goto FOUND;
			}
		}
		foreach (sort(keys(%values2))) {
			my($name, $type, $data) = @{$values2{$_}};
			$data =~ s/\"//g;
			if($data =~ /steam.exe/){
				$data = (split(/steam.exe/,$data,2))[0];
				$registry = $data .'steamapps\common\killingfloor';
				goto FOUND;
			}
		}
		foreach (sort(keys(%values3))) {
			my($name, $type, $data) = @{$values3{$_}};
			$data =~ s/\"//g;
			if($data =~ /steam.exe/){
				$data = (split(/steam.exe/,$data,2))[0];
				$registry = $data .'steamapps\common\killingfloor';
				goto FOUND;
			}
		}
		foreach (sort(keys(%values4))) {
			my($name, $type, $data) = @{$values4{$_}};
			$data =~ s/\"//g;
			if($data =~ /steam.exe/){
				$data = (split(/steam.exe/,$data,2))[0];
				$registry = $data .'steamapps\common\killingfloor';
				goto FOUND;
			}
		}
	}
	FOUND:

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
	open(F,"<$steampfad\\Cache\\cache.ini");
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

		if(!-e("$steampfad\\$notcache\\$datei")){
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
		unlink("$steampfad\\Cache\\$key.uxx");
	}
	close(F);

	open(F,">$steampfad\\Cache\\cache.ini");
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

Games::Killingfloor::Mapcache is Copyright (c) 2010 Stefan Gipper
All rights reserved.

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

=head1 SEE ALSO



=cut
