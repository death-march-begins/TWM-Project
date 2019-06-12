#!/usr/bin/perl
#
# Author : Andika Pratama
# April 2019
# 
# Department of Informatics
# College of Science, Syiah Kuala University

use strict;
use Lingua::EN::Bigram;
use File::Basename;

#Inisialisasi kamus motor
my $PATHFITUR=$ARGV[0];
my $FILEOUTPUT = $ARGV[1];

if (! $FILEOUTPUT) {
  print "Cara jalankan: $0 <PATHFILE> <Output>\n";
  exit;
}

my $PATHOUTPUT = dirname($FILEOUTPUT);
$FILEOUTPUT= basename($FILEOUTPUT, ".arff");

generateFitur("45%"); # untuk kamus tresshold 45%
generateFitur("50%"); # untuk kamus tresshold 50%

sub generateFitur {
	my $tresshold= $_[0];
	my $PATH="clean-dictionary/$tresshold";
	my $kamusMotor1g = `cat $PATH/clean-1b-grams-motor-$tresshold.txt`;
	my $kamusMotor2g = `cat $PATH/clean-2b-grams-motor-$tresshold.txt`;
	my $kamusMotor3g = `cat $PATH/clean-3b-grams-motor-$tresshold.txt`;

	# #Inisialisasi kamus mobil
	my $kamusMobil1g = `cat $PATH/clean-1b-grams-mobil-$tresshold.txt`;
	my $kamusMobil2g = `cat $PATH/clean-2b-grams-mobil-$tresshold.txt`;
	my $kamusMobil3g = `cat $PATH/clean-3b-grams-mobil-$tresshold.txt`;

	#Deklarasi objek
	my $ngram = Lingua::EN::Bigram->new;

	################################################################

	#Load kamus Motor 1 gram
	my %hashKamusMotor1g;
	my @isiKamusMotor1g= split /\n/, $kamusMotor1g;

	foreach my $x (@isiKamusMotor1g) {
		my ($norm, $kata) = split /\t/,$x;  
		$hashKamusMotor1g{$kata}=$norm;
	}

	#Load kamus Motor 2 gram
	my %hashKamusMotor2g;
	my @isiKamusMotor2g= split /\n/, $kamusMotor2g;

	foreach my $x (@isiKamusMotor2g) {
		my ($norm, $kata) = split /\t/,$x;  
		$hashKamusMotor2g{$kata}=$norm;
	}

	#Load kamus Motor 3 gram
	my %hashKamusMotor3g;
	my @isiKamusMotor3g= split /\n/, $kamusMotor3g;

	foreach my $x (@isiKamusMotor3g) {
		my ($norm, $kata) = split /\t/,$x;  
		$hashKamusMotor3g{$kata}=$norm;
	}

	#Load kamus Mobil 1 gram
	my %hashKamusMobil1g;
	my @isiKamusMobil1g= split /\n/, $kamusMobil1g;

	foreach my $x (@isiKamusMobil1g) {
		my ($norm, $kata) = split /\t/,$x;  
		$hashKamusMobil1g{$kata}=$norm;
	}

	#Load kamus Mobil 2 gram
	my %hashKamusMobil2g;
	my @isiKamusMobil2g= split /\n/, $kamusMobil2g;

	foreach my $x (@isiKamusMobil2g) {
		my ($norm, $kata) = split /\t/,$x;  
		$hashKamusMobil2g{$kata}=$norm;
	}

	#Load kamus Mobil 3 gram
	my %hashKamusMobil3g;
	my @isiKamusMobil3g= split /\n/, $kamusMobil3g;

	foreach my $x (@isiKamusMobil3g) {
		my ($norm, $kata) = split /\t/,$x;  
		$hashKamusMobil3g{$kata}=$norm;
	}
	##################################################################################

	#file bagian

	my @category = ("mobil", "motor");
	my @bagianFIle = ("title", "atas", "tengah1", "tengah2", "bawah");
	open OUT, "> $PATHOUTPUT/$FILEOUTPUT-th-$tresshold.arff";
	print OUT "\@relation $FILEOUTPUT\n\n";
	print OUT "\@attribute Class {mobil,motor}\n";

	for (my $x = 0; $x < @category; $x++) {
		for (my $i = 0; $i < @bagianFIle; $i++) {
			for (my $n = 1; $n <=3; $n++) {
				print OUT "\@attribute $category[$x]_$bagianFIle[$i]_$n numeric\n";
			}
		}
	}

	print OUT "\n\@data\n";

	# Untuk setiap category
	for (my $var = 0; $var < @category; $var++) {
		my $listFile= `ls -v $PATHFITUR/$category[$var]/`;
		my @listFitur = split /\n/, $listFile;

		#Untuk setiap file yang akan dibangun fitur
		foreach my $file (@listFitur) {
			my $isi = `cat $PATHFITUR/$category[$var]/$file`;
			
			$isi=~ s/\'|\?\!//g;
			my $noMobil=0;
			my $noMotor=12;

			my $bagianMobil="";
			my $bagianMotor="";
			print "\n\n$file";
			print "\n\n$category[$var] ";
			print OUT "$category[$var]";	

			# untuk setiap bagianFIle
			for (my $i = 0; $i < @bagianFIle; $i++) {
				my $isiDalam;
				if ($i==0) {
					$isi =~ /<title>(.*?)<\/title>/;
					$isiDalam =$1;
				} 
				if ($i==1) {
					$isi =~ /<atas>(.*?)<\/atas>/;
					$isiDalam =$1;
				}
				 if ($i==2) {
					$isi =~ /<tengah1>(.*?)<\/tengah1>/;
					$isiDalam =$1;
				} 

				 if ($i==3) {
					$isi =~ /<tengah2>(.*?)<\/tengah2>/;
					$isiDalam =$1;
				} 
				if ($i==4) {
					$isi =~ /<bawah>(.*?)<\/bawah>/;
					$isiDalam =$1;
				}

				# untuk setiap gram kata nya
				for (my $n = 1; $n <=3; $n++) {
					my $countGram = 0;
					my $countFindMobil = 0;
					my $countFindMotor =0;
					$ngram -> text($isiDalam);
					my @gramIsi = $ngram->ngram($n);;
					
					# untuk setiap kata tergantung gramnya
					foreach my $gram (@gramIsi) {
						next if ($gram =~ /[\.|\?\*|\,]/);
						if ($hashKamusMobil1g{$gram}) {
							$countFindMobil++;
						}

						if ($hashKamusMobil2g{$gram}) {
							$countFindMobil++;
						}

						if ($hashKamusMobil3g{$gram}) {
							$countFindMobil++;
						}

						if ($hashKamusMotor1g{$gram}) {
							$countFindMotor++;
						}

						if ($hashKamusMotor2g{$gram}) {
							$countFindMotor++;
						}

						if ($hashKamusMotor3g{$gram}) {
							$countFindMotor++;
						}

						$countGram++;
					}
					$noMobil++;
					$noMotor++;
					my $scoreMobil;
					my $scoreMotor;
					if ($countGram==0) {
						$scoreMobil=0;
						$scoreMotor=0;
					} else {
						$scoreMobil = $countFindMobil/$countGram;
						$scoreMotor = $countFindMotor/$countGram;
					}
					$bagianMobil="$bagianMobil,$scoreMobil";			
					$bagianMotor="$bagianMotor,$scoreMotor";			
				}
				
			}
			print "$bagianMobil $bagianMotor\n";	
			print OUT "$bagianMobil,$bagianMotor\n";	


		}
	}
	close OUT;
}


	