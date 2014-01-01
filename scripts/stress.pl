#!/usr/bin/perl
use strict;
use File::Find;
use URI::Escape ('uri_escape');
use LWP;
use POSIX ();

my $baseurl = "http://localhost:8080/SQLForwarder/SQLForwarder?query=";
my $iterations = 40;
my $threads = 100;
my @queries;
my $browser = LWP::UserAgent->new;

if($ARGV[0] =~ /^-+help$/ || scalar(@ARGV) > 2 || scalar(@ARGV) < 1) {
        die("Usage: stress.pl <exercises base dir>");
}



# - retrieves our .ex files and parses the queries out of them
find({ wanted => \&processFile, no_chdir => 1 }, $ARGV[0]);
my $threadnum = $threads-1;
for(my $thread = 0; $thread < $threads-1; $thread++) {
	my $tnum = fork();
	if($tnum == 0) {
		$threadnum = $thread;
		last;
	}
}
	
for(my $i = 0; $i < $iterations; $i++) {
	my $qnum = int(rand(scalar(@queries)));
	print "$threadnum ITER: $i QNUM: $qnum\n";
	query($queries[$qnum]);
}

if($threadnum == $threads - 1) {
	$SIG{CHLD} = sub {
		while () {
			my $child = waitpid -1, POSIX::WNOHANG;
			last if $child <= 0;
			my $localtime = localtime;
			print "Parent: Child $child was reaped - $localtime.\n";
		}
	};
}



print "END\n";

sub query {
	my $query = shift;
	$query = uri_escape($query);
	my $response = $browser->get( $baseurl.$query );
	if(!$response->is_success) {
		print "FAILURE $threadnum : " . $response->status_line . " " . $response->content . "\n";
	} else {
		print $response->status_line . "\n";
	}
}


sub processFile {
	my $file = $_;
	if (-f $file && $file !~ /\.svn/ && $file =~ /\.ex$/) {
		open CONFIG, "<","$file" or die $!;
		my @config = <CONFIG>;
		close CONFIG;
		push(@queries,parseConfig(\@config));
	}
}

sub parseConfig {
        my $data = shift;

	my $inquery = 0;
        my $query = "";
        foreach my $line(@$data) {
                chomp($line);
                if($line =~ /^\s*\|QUERY\|\s*/) {
                        $query =~ s/\s+$//sg;
			$inquery = 1;
		} elsif ($line =~ /^\s*\|([^|]*)\|\s*/ && $inquery) {
			last;
                } else {
			if($inquery) {
                        	$query .= $line."\n";
			}
                }
        }
	return $query;
}

