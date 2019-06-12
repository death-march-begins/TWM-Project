#!/usr/bin/perl

# two-grams.pl 
# Digunakan untuk membangkitkan kamus 2-gram
#
# Taufik Fuadi Abidin
# Mei 2011

use strict;
use Lingua::EN::Bigram;

# Argumen
my ($sourcePATH, $category) = @ARGV;
if (! $sourcePATH || ! $category) {
  print "Cara jalankan: $0 <Path Source> <Category>\n";
  exit;
}

# PATH output
my $PATH = "kamus";
open TOFILE, "> $PATH/2b-grams-$category.txt" or die "Cannot Open File!!!";

# load stopwords
my %stopwords;
loadStopwords(\%stopwords);

# mendapatkan list nama file
my $files = `ls -v $sourcePATH`;

# masukan list nama file kedalam array
my @listFile = split('\n',$files);

# buat objek ngrams
my $ngrams = Lingua::EN::Bigram->new;

# deklarasi Hash untuk menyimpan data kamus
my %hashGram;

foreach my $file (@listFile) {
	# masukkan isifile kedalam $text
	my $text = `cat $sourcePATH/$file`;
	$text = loadText($text); # loadText mengembalikan isi file tanpa tag <title> dll.

	my @sentences = split /\, *|\. *|\: *|\'/, $text;  # pisahkan perkalimat
	foreach my $sentence (@sentences) {
		
		$ngrams->text($sentence);
		my $bigram_count = $ngrams->bigram_count;
		foreach my $bigram (keys %$bigram_count ) {
			my ( $first_token, $second_token ) = split / /, $bigram;
	
			# skip stopwords and punctuation
			next if ( $first_token eq '');
			next if ( $second_token eq '');
			next if ( $stopwords{ $first_token } );
			next if ( $first_token =~ /[,.?!:;()\-]/ );
			next if ( $stopwords{ $second_token } );
			next if ( $second_token =~ /[,.?!:;()\-]/ );
			
			# cek jika kata ada dalam kamus
			if ($hashGram{$bigram}) {
				$hashGram{$bigram}+=$$bigram_count{$bigram};
			} else {
				$hashGram{$bigram}=$$bigram_count{$bigram};
			}

		}
	}
}

# print to file
foreach my $isi (keys %hashGram) {
	print TOFILE "$hashGram{$isi}\t$isi\n"
}

close TOFILE;



# load stopword function
sub loadStopwords 
{
  my $hashref = shift;
  open IN, "< $PATH/stopword.txt" or die "Cannot Open File!!!";
  while (<IN>)
  {
    chomp;
    if(!defined $$hashref{$_})
    {
       $$hashref{$_} = 1;
    }
  }  
}

# load text function
sub loadText {
	my $text = shift;

	my ($title ,$atas, $tengah, $bawah);

	if ($text =~ /<title>(.*?)<\/title/) {
		$title=$1;
	}

	if ($text =~ /<atas>(.*?)<\/atas/) {
		$atas=$1;
	}

	if ($text =~ /<tengah>(.*?)<\/tengah/) {
		$tengah=$1;
	}

	if ($text =~ /<bawah>(.*?)<\/bawah/) {
		$bawah=$1;
	}

	my $content = "$title. $atas$tengah$bawah";
	return $content;
}
  
