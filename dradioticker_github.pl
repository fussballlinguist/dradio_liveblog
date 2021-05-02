#! /usr/bin/perl -w

use strict;
use warnings;
use HTML::Entities;
use HTML::TreeBuilder::XPath;
use Encode;
use utf8;
use open ':std', ':encoding(utf8)';
$| = 1;

# A scraping script fpr dradio.de Corona live blog posts by Simon Meier-Vieracker @fussballinguist

# Define output folder:
my $path = "/Users/simon/Korpora/Corona/2021_05/";

# Define input file with URLs:
open IN, " < /Users/simon/Korpora/Corona/dlfticker_urls.txt" or die $!;

# No changes below this line
my @urls;
while (<IN>) {
	chomp($_);
	push @urls, $_;
}
foreach my $url (@urls) {
	my $html = qx(curl -s '$url');
	my $tree = HTML::TreeBuilder::XPath->new_from_content($html);
	my $date;
	if ($html =~ /<time>(.+?)</) {
		$date = $1;
		$date =~ s/\xa0/ /g;
		$date = clean_date($date);

	}
	print "$date\n";
	my @ps = $tree->findvalues('//p');
	my $filename = $path . $date . ".xml";
	open OUT, "> $filename" or die $!;
	print OUT "<text date=\"$date\" url=\"$url\">\n";
	foreach my $p (@ps) {
		print OUT "\t<p>$p</p>\n";
	}
	print OUT "</text>\n";
}

sub clean_date{
	my $path = $_[0];
	if ($path =~ /^(\d)\. (.+?)$/) {
		$path = "0$1. $2";
	}
	$path =~ s/Januar/01/g;
	$path =~ s/Februar/02/g;
	$path =~ s/März/03/g;
	$path =~ s/April/04/g;
	$path =~ s/Mai/05/g;
	$path =~ s/Juni/06/g;
	$path =~ s/Juli/07/g;
	$path =~ s/August/08/g;
	$path =~ s/September/09/g;
	$path =~ s/Oktober/10/g;
	$path =~ s/November/11/g;
	$path =~ s/Dezember/12/g;
	if ($path =~ /(\d+)\. (\d+) (\d+)/) {
		$path = "$3-$2-$1";
	}
	return($path);
}