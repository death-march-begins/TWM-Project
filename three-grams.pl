#!/usr/bin/perl

# two-grams.pl 
# Digunakan untuk membangkitkan kamus 2-gram
#
# Taufik Fuadi Abidin
# Mei 2011

use strict;
use Lingua::EN::Bigram;

my ($sourcePATH, $category) = @ARGV;
if (! $sourcePATH || ! $category) {
  print "Cara jalankan: $0 <Path Source> <Category>\n";
  exit;
}

my $PATH = "kamus";
open TOFILE, "> $PATH/3b-grams-$category.txt" or die "Cannot Open File!!!";

# load stopwords
my %stopwords;
loadStopwords(\%stopwords);

# get name file
my $files = `ls -v $sourcePATH`;

# split name file to array
my @listFile = split('\n',$files);

# build n-grams
my $ngrams = Lingua::EN::Bigram->new;

my %hashGram;

foreach my $file (@listFile) {

	my $text = `cat $sourcePATH/$file`;
	$text = loadText($text);

	my @sentences = split /\, *|\. *|\: *|\'/, $text;
	foreach my $sentence (@sentences) {
		
		$ngrams->text($sentence);

		# get bi-gram counts
		my $trigram_count = $ngrams->trigram_count;

		# print "##Bi-grams (T-Score, count, bi-gram)\n";
		#foreach my $bigram ( sort { $$tscore{ $b } <=> $$tscore{ $a } } keys %$tscore ) {
		foreach my $trigram (keys %$trigram_count ) {
			# print "$trigram\n";
			# get the tokens of the bigram
			my ( $first_token, $second_token, $third_token ) = split / /, $trigram;
			
			# skip stopwords and punctuation
			next if ( $first_token eq '');
			next if ( $second_token eq '');
			next if ( $third_token eq '');
			next if ( $stopwords{ $first_token } );
			next if ( $first_token =~ /[,.?!:;()\-]/ );
			next if ( $stopwords{ $second_token } );
			next if ( $second_token =~ /[,.?!:;()\-]/ );
			next if ( $stopwords{ $third_token } );
			next if ( $third_token =~ /[,.?!:;()\-]/ );
			
			# cek jika kata ada dalam kamus
			if ($hashGram{$trigram}) {
				$hashGram{$trigram}+=$$trigram_count{$trigram};
			} else {
				$hashGram{$trigram}=$$trigram_count{$trigram};
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
  
