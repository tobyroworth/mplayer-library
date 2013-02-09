#!/usr/bin/perl

use Switch;

if (@ARGV == 0) {
	die("Usage:\n\tvideo list\n\tvideo rip 'format' 'DVD title [and chapter]' 'title'\n\tvideo play 'STRING' [episode number]");
}

$method = $ARGV[0];

if ($method eq "list") {

	$indexfile = "index";
	
	open(INDEX, $indexfile) or die("Unable to open index\n");
	
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

	$indexfile = "index";
	
	open(INDEX, $indexfile) or die("Unable to open index\n");
	
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
						system("mplayer", "-fs", @options, $filename);
						break;
					}
					case "multimovie" {
						@filenames = split(/,/, $filename);
						system("mplayer", "-fs", @options, @filenames);
						break;
					}
					case "series" {
						$episode = $ARGV[2];
						@filenameparts = split(/,/, $filename);
						$folder = $filenameparts[0];
						$maxepisode = $filenameparts[1];
						$ext = $filenameparts[2];
						
						if ($episode eq "all") {
							for ($i = 1; $i <= $maxepisode; $i++) {
								push(@filename,"$folder/$i.$ext");
							}
						} elsif ($episode > 0 && $episode <= $maxepisode) {
							@filename = "$folder/$episode.$ext";
						} else {
							die("ERROR: Episode out of Range\n");
						}
						
						system("mplayer", "-fs", @options, @filename);
						break;
					}
				}
			}
		}
	}
	
	close(INDEX);
} elsif ($method eq "dvd") {
	
	$title = $ARGV[1];

	system("mplayer", "-fs", "-alang", "en", "-slang", "en", "-forcedsubsonly", "DVD://$title");
} else {
	die("ERROR: Did not recognise method\n");
}

