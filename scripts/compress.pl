#!/usr/bin/perl
use Cwd 'abs_path';
use File::Basename;
use File::Find;
use File::Path;
use File::Copy;
use strict;
my $compresseddir = "../site/website-compressed";
my $uncompresseddir = "../site/website";
my $dirname = dirname(abs_path($0));
print $dirname."\n";
`cd $dirname`;
`rm -rf $compresseddir`;
`mkdir $compresseddir`;
find({ wanted => \&processFile, no_chdir => 1 }, $uncompresseddir);

sub processFile {
	my $file = $_;

	if (-d $file) {
		return;
	}

	my $path = dirname($file);
	$path =~ s/^$uncompresseddir/$compresseddir/;
	my $newfile = $file;
	$newfile =~ s/^$uncompresseddir/$compresseddir/;

	if(! -d $path) {
		my $dirs = eval { mkpath($path) };
		die "Failed to create $path: $@\n" unless $dirs;
	}
	print $path."\n";
	print $newfile."\n";

	copy($file,$path) or die "Failed to copy $file: $!\n";

	if ($file !~ /$uncompresseddir\/lib/ && $file !~ /\.gz$/) {
		#TODO: bail out on error
		if($newfile =~ /\.html$/) {
			`java -jar lib/htmlcompressor.jar $newfile > $newfile.tmp`;
			`mv $newfile.tmp $newfile`;
		}
		if($newfile =~ /\.js$/) {
			`java -jar lib/yuicompressor.jar --type js $newfile > $newfile.tmp`;
			`mv $newfile.tmp $newfile`;
		}
		if($newfile =~ /\.css$/) {
			`java -jar lib/yuicompressor.jar --type css $newfile > $newfile.tmp`;
			`mv $newfile.tmp $newfile`;
		}
	}
	`gzip -c --best --force $newfile > $newfile.gz`

}
