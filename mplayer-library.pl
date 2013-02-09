#!/usr/bin/perl

use Switch;

if (@ARGV == 0) {
	die("Usage:\n\tvideo list\n\tvideo rip 'format' 'DVD title [and chapter]' 'title'\n\tvideo play 'STRING' [episode number]");
}

$configFile=$ENV{"HOME"} . "/.mplayer-library/config";
my $libraryBaseDir = "/";
my $indexFile = "";


open(CONFIG, $configFile) or die("Could not open config file at: $configFile");

@config = <CONFIG>;

close(CONFIG);

foreach $con (@config) {
    chomp($con);
    if ($con =~ m/libraryBaseDir=*/) {
	@parts = split(/=/, $con);
	$libraryBaseDir = $parts[1] . '/';
	#print("[Config] found library base directory at $libraryBaseDir\n");
    } elsif ($con =~ m/indexFile=/) {
	@parts = split(/=/, $con);
	$indexFile = $parts[1];
	#print("[Config] found index file at $indexFile\n");
    }
}

@mplayerCommand=(
        'mplayer',
	'-vo',
	'gl',
	'-ao',
	'pulse',
	'-vf',
	'pp=lb',
	'-framedrop',
	'-alang',
	'en',
	'-slang',
	'en',
	'-forcedsubsonly',
	'-fs',
	'-fixed-vo'
);

$method = $ARGV[0];

if ($method eq "list") {

	open(INDEX, $indexFile) or die("Unable to open index\n");
	
	@index = <INDEX>;
	
	foreach $ind (@index) {
		if ($ind =~ m/^#/) {
			#comment line
		} elsif ($ind =~ m/^$/) {
			#blank line
		} else {
			@parts = split(/\t/, $ind);
			print("$parts[0]\n");
		}
	}
	
	close(INDEX);

} elsif ($method eq "rip") {

	$format = $ARGV[1];
	$filename = $ARGV[2];
	$title = "";
	if (@ARGV > 3) {
		$title = $ARGV[3];
	}

	if ($format eq "mpeg2") {
		print "Ripping MPEG2\n";
		print system("./rip_mpeg2.sh", "-i", "$title", "-o", "$filename");
	} elsif ($format eq "mpeg4") {
		print "Ripping MPEG4\n";
		print system("./rip_mpeg4.sh", "-i", "$title", "-o", "$filename");
	} elsif ($format eq "x264") {
		print "Ripping h264\n";
		system("./rip_x264.sh", "-i", "$title", "-o", "$filename");
	} else {
		die("ERROR: Unsupported rip format\n");
	}

} elsif ($method eq "play") {
	
	$playname = $ARGV[1];
	
	open(INDEX, $indexFile) or die("Unable to open index\n");
	
	@index = <INDEX>;
	
	foreach $ind (@index) {
		if ($ind =~ m/^#/) {
			#comment line
		} elsif ($ind =~ m/^$/) {
			#blank line
		} else {
			@parts = split(/\t/, $ind);
			$name = $parts[0];
			$mode = $parts[1];
			$filename = $parts[2];
			$options = $parts[3];
			
			chomp($name);
			chomp($mode);
			chomp($filename);
			chomp($options);
			
			@options = split(/ /, $options);
			
			if ($name eq $playname) {
				switch ($mode) {
					case "movie" {
					    print(@mplayerCommand);
						system(@mplayerCommand, @options, $libraryBaseDir . $filename);
						break;
					}
					case "multimovie" {
						@filenames = split(/,/, $filename);
						for($i=0; $i < @filenames; $i++) {
						    $filenames[$i] = $libraryBaseDir . $filenames[$i];
				                }
						system(@mplayerCommand, @options, @filenames);
						break;
					}
					case "series" {
						$episode = $ARGV[2];
						@filenameparts = split(/,/, $filename);
						$folder = $libraryBaseFir . $filenameparts[0];
						$maxepisode = $filenameparts[1];
						$ext = $filenameparts[2];
						
						if ($episode eq "all") {
							for ($i = 1; $i <= $maxepisode; $i++) {
								push(@filename, $libraryBaseDir . "$folder/$i.$ext");
							}
						} elsif ($episode > 0 && $episode <= $maxepisode) {
							@filename = $libraryBaseDir . "$folder/$episode.$ext";
						} else {
							die("ERROR: Episode out of Range\n");
						}
						
						system(@mplayerCommand, @options, @filename);
						break;
					}
				}
			}
		}
	}
	
	close(INDEX);
} elsif ($method eq "dvd") {
	
	$title = $ARGV[1];

	system(@mplayerCommand, "DVD://$title");
} else {
	die("ERROR: Did not recognise method\n");
}

