#! /usr/bin/env perl
use strict;
use LWP::UserAgent;
use File::Find;
use JSON;
use HTML::Make;
use JSON::Parse 'parse_json';

my $tomcaturl = "http://localhost:8080/SQLForwarder/SQLForwarder";
my $outputloc = "../site/website/questions/";
my $templateloc = "../site/website/questions/template.html";
my $questionsloc = "../questions/";
my @dirs = ("basic", "joins", "updates", "aggregates", "date", "string", "recursive");
#categories data structure ends up like: category -> files -> file metadata
my $categories = {};
my $emptyfile = {'title' => '', 'filenamehtml' => '#'};

my $stripNums;
if($ARGV[0] =~ /^-+help$/ || scalar(@ARGV) > 2 || scalar(@ARGV) < 1) {
	die("Usage: processdocs.pl <exercises base dir> [strip prepended file numbers]");
}
if(scalar(@ARGV) > 1) {
	$stripNums = $ARGV[1];
}

#find all files under the specified directory, passing them to processFile
# - retrieves our .ex files and parses them into $categories
find({ wanted => \&processFile, no_chdir => 1 }, $ARGV[0]);


#loop through each directory of questions, producing exercise and listing files
for(my $i = 0; $i < scalar(@dirs); $i++) {
	my $dir = $dirs[$i];
	my $nextdir = $dirs[$i+1];
	if(-e "$outputloc/$dir") {
		print "REMOVING $outputloc/$dir\n";
		`rm -rf $outputloc/$dir`;
	}
	my @files = keys(%{$categories->{$dir}});
	#sort the files.  They have a number prepended (eg 0014000) that dictates
	#their output order.  Number is fixed length, so we can just use string
	#sort.  We do optionally strip out this number from the file name, so we store
	#a separate sort key in the categories data structure.
	@files = sort { $categories->{$dir}->{$a}->{'filenamesort'} cmp $categories->{$dir}->{$b}->{'filenamesort'} } @files;
	print(@files);

	my $dlisting = "";
	my $firstpage = "";
	my @listingPageIDs = ();
	#look through files in order.  Order is necessary so we can maintain links
	#to previous and next questions
	for(my $file = 0; $file < scalar(@files); $file++) {
		print "FILE $file\n";
		my $lastfile;
		my $lastfilename;
		my $curfile;
		my $curfilename;
		my $nextfile;
		my $nextfilename;

		#Produce the previous file for breadcrumbs.  If no previous file, link to the listing
		#for the category
		if($file == 0) {
		       	$lastfilename = "../$dir/";
		       	$lastfile = {'title' => 'Back to listing', 'filenamehtml' => "../$dir/", 'type' => 'listing'};
		}  else {
			$lastfilename = $files[$file-1];
			$lastfile = $categories->{$dir}->{$lastfilename};
		}

		#Produce the next file for breadcrumbs.  If no next file found, link to next category listing.
		#if no category found, you're at the end.
		if ($file >= scalar(@files) -1) {
			if($nextdir) {
		        	$nextfilename = "../$nextdir/";
		        	$nextfile = {'title' => 'Next Category', 'filenamehtml' => "../$nextdir/", 'type' => 'listing'};
			} else {
				$nextfile = $emptyfile;
			}
		} else {
			$nextfilename = $files[$file+1];
			$nextfile = $categories->{$dir}->{$nextfilename};

		}
		print "\n".$lastfilename . " <> " . $nextfilename."\n";
		$curfile = $categories->{$dir}->{$files[$file]};
		if($file == 0) {
			$firstpage = $curfile->{'filenamehtml'};
		}

		#Process the exercise file into an HTML file, based on the exercise template
		my $exerciseData = processHTML($lastfile, $curfile, $nextfile);
		my $description = $exerciseData->{'|QUESTIONNAME|'};
		#add the page to a list of IDs
		push(@listingPageIDs, $exerciseData->{'|PAGEID|'});
		my $link = $curfile->{'filenamehtml'};

		#add the exercise file to the category listing
		$dlisting .= "<li><span class=\"listingitem\"><a class=\"listlink\" href='$link'>$description</a></span></li>\n";
	}

	#build the directory listing file
	processListing($dir, $dlisting, $firstpage, \@listingPageIDs);

}

#produce the listing (index.html) for a category.  Basically just a matter
#of removing comments, subbing in the list of all questions
sub processListing {
	my $dir = shift;
	my $list = shift;
	my $firstpage = shift;
	my @listPageIDs = @{shift @_};
	#this writes the index file for the category

	mkdir "$outputloc/$dir";

	open CONFIG, "<","$questionsloc/$dir/index" or die $!;
	my @config = <CONFIG>;
	close CONFIG;
	my $configData = parseConfig(\@config);
	
	print "$outputloc/$dir/index.html\n";
	open LISTTEMPLATE, "<","$outputloc/template-listings.html" or die $!;
	my @template = <LISTTEMPLATE>;
	close LISTTEMPLATE;

	print "PAGE: $firstpage\n";
	open DIRLISTING, ">","$outputloc/$dir/index.html" or die $!;
	my $commenton = 0;
	foreach my $line(@template) {
		my $chompedline = $line;
		chomp($chompedline);
		$chompedline =~ s/\s//g;
		if($line =~ /<!-- FILLER -->/) {
			$commenton = !$commenton;
		} elsif($commenton) {
		
		} elsif($line =~ /\|LISTING\|/) {
			print DIRLISTING $list;
		} elsif($line =~ /\|FIRSTPAGE\|/) {
			$line =~ s/\|FIRSTPAGE\|/$firstpage/;
			print DIRLISTING $line;
		} elsif($line =~ /\|PAGEIDS\|/) {
			my $pageIDs = "\"" . join("\",\"", @listPageIDs) . "\"";
			print $pageIDs."\n\n";
			$line =~ s/\|PAGEIDS\|/$pageIDs/;
			print DIRLISTING $line;
		} elsif(defined $configData->{$chompedline}) {
			print DIRLISTING $configData->{$chompedline};
		} else {
			print DIRLISTING $line;
		}

	}

	close DIRLISTING;
}

#For a given .ex file, output the appropriate HTML file
#mostly this involves replacing |<NAME>| segements within
#the template file with 
#appropriate values we build up in parseConfig, plus a bit of extra
#data like next page and previous page
sub processHTML {
	my $lastfile = shift;
	my $curfile = shift;
	my $nextfile = shift;
	print ".." . $curfile->{'filepath'};
	
	open FILE, "<",$curfile->{'filepath'} or die $!;
	my @filedata = <FILE>;
	close FILE;

	my $exerciseData = parseConfig(\@filedata);

        my $tableToReturn = $exerciseData->{'|RETURNTABLE|'};
	my $query = $exerciseData->{'|QUERY|'};
	print (%$exerciseData);
	my ($resultsTable,$jsonTable)  = genResults($query, $tableToReturn);
	my $commenton = 0;

	open TEMPLATE, "<",$templateloc or die $!;
	my @template = <TEMPLATE>;
	close TEMPLATE;
	
	print $curfile->{'filepathhtml'}."\n";
	if(! -e $curfile->{'dirhtml'}) {
		mkdir $curfile->{'dirhtml'};
	}
	open OUT, ">",$curfile->{'filepathhtml'} or die $!;

	foreach my $line(@template) {
		my $chompedline = $line;
		chomp($chompedline);
		$chompedline =~ s/\s//g;

		#print '"'.$chompedline.'"'."\n";

		if($line =~ /<!-- FILLER -->/) {
			$commenton = !$commenton;
		} elsif($commenton) {

		} elsif($line =~ /\|SORTED\|/) {
			my $sorted = $exerciseData->{'|SORTED|'};
			$line =~ s/\|SORTED\|/$sorted/;
			print OUT $line;
		} elsif($line =~ /\|WRITEABLE\|/) {
			my $writeable = $exerciseData->{'|WRITEABLE|'};
			$line =~ s/\|WRITEABLE\|/$writeable/;
			print OUT $line;
		} elsif($line =~ /\|RETURNTABLE\|/) {
			my $returntable = $exerciseData->{'|RETURNTABLE|'};
			$line =~ s/\|RETURNTABLE\|/$returntable/;
			print OUT $line;
		} elsif($line =~ /\|PAGEID\|/) {
			my $pageID = $exerciseData->{'|PAGEID|'};
			$line =~ s/\|PAGEID\|/$pageID/;
			print OUT $line;
		} elsif($line =~ /\|RESULTS\|/) {
			print OUT $resultsTable;
		} elsif($line =~ /\|JSONRESULTS\|/) {
			$line =~ s/\|JSONRESULTS\|/$jsonTable/;
			print OUT $line;
		} elsif($line =~ /\|ANSWER\|/) {
			print OUT $exerciseData->{'|ANSWER|'};
		} elsif($line =~ /\|PREVPAGE\|/) {
			my $value = getLinkFromFileDesc($lastfile, 'Previous Exercise');
			$line =~ s/\|PREVPAGE\|/$value/;
			print OUT $line;
		} elsif($line =~ /\|NEXTPAGE\|/) {
			my $value = getLinkFromFileDesc($nextfile, 'Next Exercise');
			$line =~ s/\|NEXTPAGE\|/$value/;
			print OUT $line;
		} elsif($line =~ /\|CATEGORY\|/) {
			my $value = ucfirst($curfile->{'dir'});
			$line =~ s/\|CATEGORY\|/$value/;
			print OUT $line;
		} elsif($line =~ /\|SHORTNAME\|/) {
			my $value = ucfirst($curfile->{'shortname'});
			$line =~ s/\|SHORTNAME\|/$value/;
			print OUT $line;
		} elsif($line =~ /\|QUERY\|/) {
			print OUT prettyQuery($query);
		} elsif(defined $exerciseData->{$chompedline}) {
			print OUT $exerciseData->{$chompedline};
		} else {
			print OUT $line;
		}
	}

#	print OUT $query."\n";
#	print OUT $resultsTable."\n";
	
	
	close OUT;

	return $exerciseData;
}

sub prettyQuery {
	my $query = shift;
	chomp $query;
	return "$query";
}

#parse a .ex file.  This just involves looking for |<NAME>| segments
#in the file and adding the data into the returned hash
sub parseConfig {
	my $data = shift;

	my $lastop = "";
	my $html = "";
	my $filedata = {};
	foreach my $line(@$data) {
		chomp($line);
		if($line =~ /^\s*\|([^|]*)\|\s*/) {
			#we're on a header line.  Check if we were previously processing
			#a different header, as we need to complete that and start the new one
			if($lastop ne "") {
				$html =~ s/\s+$//sg;
				$filedata->{$lastop} = $html;
			}
			$lastop = "|$1|";
			$html = "";
			print "\"$lastop\"\n";
		} else {
			#we're on a data line.  Do any replacements to support our shortcuts - for example, <c> turns
			#into a code span
			$line =~ s/<c>/<span class="code">/g;
			$line =~ s/<\/c>/<\/span>/g;
			$line =~ s/<sql>/<\/div><\/div><div class="row"><div class="span12 answerdiv" style="opacity:0;"><div><pre class="secondaryanswerdiv prettyprint lang-sql">/g;
			$line =~ s/<\/sql>/<\/pre><\/div><\/div><\/div><div class="row"><div class="span8 answerdiv" style="opacity:0;">/g;
			$html .= $line."\n";
		}
	}
	if($lastop ne "") {
		$html =~ s/\s+$//sg;
		$filedata->{$lastop} = $html;
	}

	return $filedata;
}

#Used to produce prev/next page breadcrumbs
sub getLinkFromFileDesc {
	my $filedesc = shift;
	my $label = shift;
	my $link = $filedesc->{'filenamehtml'};
	my $type = $filedesc->{'type'};
	if ($type eq 'listing') {
		my $title = $filedesc->{'title'};
		return "<a href=\"$link\">$title</a>";
	} elsif ($type eq 'exercise') {
		return "<a href=\"$link\">$label</a>";
	} else {
		return "Questions Complete!";
	}
}

#Used during the find file process - finds each file and processes out information like its name
sub processFile {
	my $file = $_;
	
	if (-f $file && $file !~ /\.svn/ && $file =~ /\.ex$/) {
		my $filepath = $file;
		$file =~ s/(.*)questions\/(.*)/\2/;
		(my $dir, my $filename) = split(/\//, $file);
		my $filenamesort = $filename;
		if($stripNums == 1) {
			$filename =~ s/^[0-9]*-//;
		}
		my $filenamehtml = $filename;
		my $shortname = $filename;
		$filenamehtml =~ s/\.ex$/\.html/;
		$shortname =~ s/\.ex$//;
		my $filedata = {
			'filenamehtml' => $filenamehtml,
			'filename' => $filename,
			'filenamesort' => $filenamesort,
			'filepath' => $filepath,
			'filepathhtml' => $outputloc.$dir."/".$filenamehtml,
			'dirhtml' => $outputloc.$dir."/",
			'shortname' => $shortname,
			'dir' => $dir,
			'type' => 'exercise'
		};
		my $filesfordir = $categories->{$dir};
		if (!defined $filesfordir) {
			$filesfordir = {};
			$categories->{$dir} = $filesfordir;
		}
		$filesfordir->{$filename} = $filedata;
		
		print $dir . " " . $filename . " " . $filenamehtml . "\n";
	}
}

#run query against tomcat server.
sub genResults {
	my $query = shift;
        my $tabletoreturn = shift;
        print "\n TABLE $tabletoreturn \n";
        my $writeable = defined ($tabletoreturn);
        print "\n WRITEABLE $writeable \n";
        my $uri = URI->new( $tomcaturl );
        $uri->query_form(query => $query, writeable => $writeable, tableToReturn => $tabletoreturn);
        my $ua = LWP::UserAgent->new;
        $ua->env_proxy;
        print "\nURI: " . $uri . "\n";
        my $response = $ua->get($uri);
        my $result;
        if ($response->is_success) {
            $result = $response->decoded_content;
        } else {
            print "\n ERROR: " . $response->decoded_content . "\n";
            die("ERROR: " . $response->status_line . "\n");
        }
        
        print "\nRESULT: " . $result . "\n";

        my $json = parse_json ($result);

        my $headers = $json->{'headers'};
        my $thead = HTML::Make->new('thead');
        my $header_row = $thead->push('tr');
        foreach my $header(@$headers) {
            $header_row->push('th', text => $header);
        }

        my $values = $json->{'values'};
        my $tbody = HTML::Make->new('tbody');
        foreach my $valuerow(@$values) {
            my $value_tr = $tbody->push('tr');
            foreach my $value(@$valuerow) {
                print "\nVALUE: $value\n";
                #$value = $value eq "0" ? "\\0" : $value;
                my $td = $value_tr->push('td');
                $td->add_text($value);
            }
        }

        my $htmltable = $thead->text . $tbody->text;
        my $jsontable = encode_json($json->{'values'});

	print $htmltable . "\n";
	print $jsontable . "\n";

	return ($htmltable, $jsontable);
}


