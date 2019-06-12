#!/usr/bin/perl
#
# Program ini digunakan untuk mengekstrak bagian konten dari sebuah file HTML
#
# Author: Taufik Fuadi Abidin
# Department of Informatics
# College of Science, Syiah Kuala Univ
# 
# Date: Mei 2011
# http://www.informatika.unsyiah.ac.id/tfa
#
# Dependencies:
# INSTALASI HTML-EXTRACTCONTENT
# See http://www.cpan.org/
#
# 1. Download HTML-ExtractContent-0.10.tar.gz and install
# 2. Download Exporter-Lite-0.02.tar.gz and install
# 3. Download Class-Accessor-Lvalue-0.11.tar.gz and install
# 4. Download Class-Accessor-0.34.tar.gz and install
# 5. Download Want-0.18.tar.gz and install
#

use strict;
use warnings;
use HTML::ExtractContent;
use File::Basename;
use POSIX;

# Cek Argumen 
my $dieArgv="Mohon ikuti contoh dibawah\nex: perl extractcontent.pl PATHFILE url.txt PATHCLEAN\n"
;
if (not defined $ARGV[0]) {
  die $dieArgv;
}

if (not defined $ARGV[1]) {
   die $dieArgv;
}

if (not defined $ARGV[2]) {
   die $dieArgv;
}

# Deklarasi variabel berisi argumen
my $nameFile = `ls -v $ARGV[0]/`;  
my @name = split ("\n", $nameFile);
my $fileUrl = `cat $ARGV[1]`;
my @urls = split("\n", $fileUrl); 
my $PATHCLEAN= "$ARGV[2]";

# Ekstrak konten seluruh file sumber
my $i=0;
foreach my $file (@name){
	$urls[$i]=~ s/$file\s+//g; # Hilangkan nama file dalam url
	print "=========================================================================\n";
	extractContent("$ARGV[0]/$file", $urls[$i]); # Panggil Subroutines/Function extractContent
	print "=========================================================================\n";
	$i++;
}

# Fungsi mengekstrak file html menjadi file file bersih
# Terdiri dari url, title, dan content (atas,tengah, bawah)
# Memiliki 2 parameter nama file dan url dalam bentuk string
sub extractContent {
	
	# Mendapatkan nama file
	my $file = $_[0];
	my $fileout = basename($file, ".html");
	$fileout = "$fileout.bersih.dat";
	print "fileout: [$fileout]\n";

	# Mendapatkan Url
	my $url = $_[1];

	# Direktori dimana file yang sudah dibersihkan disimpan
	$fileout = "$PATHCLEAN/$fileout";
	print "File-clean: $fileout\n";

	# Buka dan Buat file out
	open OUT, "> $fileout" or die "Cannot Open File!!!";

	# Buat Object
	my $extractor = HTML::ExtractContent->new;
	my $html = `cat $file`;

	# Print Url dalam fileout
	print OUT "<url>$url</url>\n";

	# Mendapatkan title dalam file HTML
	if( $html =~ /<title.*?>(.*?)<\/title>/){
	  my $title = $1;
	  $title = clean_str($title);
	  print "<title>$title</title>\n";
	  print OUT "<title>$title</title>\n";  # print title kedalam fileout
	}

	# Mendapatkan Content
	$extractor->extract($html);
	my $content = $extractor->as_text;
	$content = clean_str($content);

	# Bagi konten perkalimat
	my @divContent = split /\.\s+|[\?\!]/, $content;
	my $sizeDivContent = @divContent;
	my $contentSize = $sizeDivContent/3;
	$contentSize = floor($contentSize);
	
	# Bagi content menjadi 3 bagian
	my $i=1;
	my @tempContent;
	foreach my $initContent(@divContent) {
		if ($i <= $contentSize) {
			push(@tempContent, "$initContent.");
			if ($i == $contentSize) {
				$content ="<atas>@tempContent</atas>\n";
				@tempContent=();
			}
		} elsif ($i <= (2*$contentSize)) {
			push(@tempContent, "$initContent.");
			if ($i == (2*$contentSize)) {
				$content ="$content<tengah>@tempContent</tengah>\n";
				@tempContent=();
			}
		} else {
			push(@tempContent, "$initContent.");
			if ($i == $sizeDivContent) {
				$content ="$content<bawah>@tempContent</bawah>\n";
				@tempContent=();
			}
		}
		$i++;
	}

	# Bersihkan content
	$content=~ s/\.\s+\.//g;
	$content=~ s/\.+/./g;

	# Print content kedalam fileout
	print OUT "$content";

	# Tutup fileout
	close OUT;
}


# Fungsi untuk membersihkan string teks dari simbol yang tidak diperlukan
# Memiliki satu parameter yaitu string teks
sub clean_str {
  my $str = shift;
  $str =~ s/>//g;  			
  $str =~ s/&.*?;//g;		
  $str =~ s/[\]\|\[\@\#\$\%\*\&\\\(\)\"]+//g; #hilangkan tanda2 didalam kurung siku
  $str =~ s/-/ /g;			# subsitusi - menjadi spasi
  $str =~ s/\n+/ /g;		# subsitusi \n menjadi spasi
  $str =~ s/\xc2\xa0/ /g; 	# subsitusi &nbsp menjadi spasi
  $str =~ s/\s+/ /g;		# subsitusi spasi, tab. dst menjadi spasi
  $str =~ s/^\s+//g;		# hapus yang spasi atau tab 1 atau lebih pada awal string
  $str =~ s/\s+$//g;		# hapus tanda spasi atau tab 1 atau lebih pada akhir string
  $str =~ s/^$//g;			
  $str =~ s/\s+\./. /g;		# subsitusi spasi titik menjadi titik spasi
  return $str;				# kembalikan string yang sudah bersih
}
