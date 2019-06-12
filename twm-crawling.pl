#!usr/bin/perl
use warnings;
use strict;

# Argumen twm-crawling.pl
my ($file, $PATH, $n) = @ARGV;

# Validasi Argumen
my $dieArgv="Mohon ikuti contoh dibawah\nex: perl twm-crawling.pl url.txt outputDst n\n";

if (not defined $file) {
  die $dieArgv;
}

if (not defined $PATH) {
   die $dieArgv;
}

# buka isi file
my $isifile = `cat $file`;
# bagi isi file
my @url = split('\n',$isifile);

# Wget berdasarkan url dalam file
my $i =1;
foreach my $isi(@url) {
	if ($i >= $n) {
		my @urls = split(' ',$isi); 
	    print "\n==================================================================\n";
	    print "Nama File : $urls[0]\n";
	    print "Wget Link : $urls[1]\n";
	    print "==================================================================\n";
	    system "wget -O $PATH$urls[0] $urls[1]";
	}
	$i++;
}
