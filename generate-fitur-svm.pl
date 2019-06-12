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
$FILEOUTPUT= basename($FILEOUTPUT, ".dat");

generateFitur("45%"); # untuk kamus tresshold 50%
# generateFitur("45%"); # untuk kamus tresshold 40%

sub generateFitur {
	my $tresshold=$_[0];
	my $PATH="kamus-bersih/neurology-oncology/$tresshold";
	my $kamusSatu1g = `cat $PATH/clean-1b-grams-neurology.-$tresshold.txt`;
	my $kamusSatu2g = `cat $PATH/clean-2b-grams-neurology.-$tresshold.txt`;
	my $kamusSatu3g = `cat $PATH/clean-3b-grams-neurology.-$tresshold.txt`;

	# #Inisialisasi kamus mobil
	my $kamusDua1g = `cat $PATH/clean-1b-grams-oncology.-$tresshold.txt`;
	my $kamusDua2g = `cat $PATH/clean-2b-grams-oncology.-$tresshold.txt`;
	my $kamusDua3g = `cat $PATH/clean-3b-grams-oncology.-$tresshold.txt`;

	#Deklarasi objek
	my $ngram = Lingua::EN::Bigram->new;

	################################################################

	#Load kamus Dua 1 gram
	my %hashkamusSatu1g;
	my @isikamusSatu1g= split /\n/, $kamusSatu1g;

	foreach my $x (@isikamusSatu1g) {
		my ($norm, $kata) = split /\t/,$x;  
		$hashkamusSatu1g{$kata}=$norm;
	}

	#Load kamus Dua 2 gram
	my %hashKamusSatu2g;
	my @isiKamusSatu2g= split /\n/, $kamusSatu2g;

	foreach my $x (@isiKamusSatu2g) {
		my ($norm, $kata) = split /\t/,$x;  
		$hashKamusSatu2g{$kata}=$norm;
	}

	#Load kamus Dua 3 gram
	my %hashKamusSatu3g;
	my @isiKamusSatu3g= split /\n/, $kamusSatu3g;

	foreach my $x (@isiKamusSatu3g) {
		my ($norm, $kata) = split /\t/,$x;  
		$hashKamusSatu3g{$kata}=$norm;
	}

	#Load kamus Satu 1 gram
	my %hashKamusDua1g;
	my @isiKamusDua1g= split /\n/, $kamusDua1g;

	foreach my $x (@isiKamusDua1g) {
		my ($norm, $kata) = split /\t/,$x;  
		$hashKamusDua1g{$kata}=$norm;
	}

	#Load kamus Satu 2 gram
	my %hashKamusDua2g;
	my @isiKamusDua2g= split /\n/, $kamusDua2g;

	foreach my $x (@isiKamusDua2g) {
		my ($norm, $kata) = split /\t/,$x;  
		$hashKamusDua2g{$kata}=$norm;
	}

	#Load kamus Satu 3 gram
	my %hashKamusDua3g;
	my @isiKamusDua3g= split /\n/, $kamusDua3g;

	foreach my $x (@isiKamusDua3g) {
		my ($norm, $kata) = split /\t/,$x;  
		$hashKamusDua3g{$kata}=$norm;
	}
	##################################################################################

	# category klasifikasi
	my @category = ("neurology", "oncology");

	my @bagianFIle = ("title", "atas", "tengah", "bawah");
	
	open OUT, "> $PATHOUTPUT/$FILEOUTPUT-th-$tresshold.dat";
	print OUT "# Reuters category \"$category[0] dan $category[1]\" ($FILEOUTPUT : 6000 positive/ 6000 negative) \n";
	
	# Untuk setiap category
	for (my $var = 0; $var < @category; $var++) {
		my $listFile= `ls -v $PATHFITUR/$category[$var]/`;
		my @listFitur = split /\n/, $listFile;

		#Untuk setiap file yang akan dibangun fitur
		foreach my $file (@listFitur) {
			my $isi = `cat $PATHFITUR/$category[$var]/$file`;
			
			$isi=~ s/\'|\?\!//g;
			my $noSatu=0;
			my $noDua=12;

			my $bagianSatu="";
			my $bagianDua="";
			print "\n\n$file";
			print "\n\n$category[$var] ";
			
			if ($category[$var] eq "neurology") {
				print OUT "+1";
			} else {
				print OUT "-1";
			}
		
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
					$isi =~ /<tengah>(.*?)<\/tengah>/;
					$isiDalam =$1;
				} 
				if ($i==3) {
					$isi =~ /<bawah>(.*?)<\/bawah>/;
					$isiDalam =$1;
				}

				# untuk setiap gram kata nya
				for (my $n = 1; $n <=3; $n++) {
					my $countGram = 0;
					my $countFindSatu = 0;
					my $countFindDua =0;
					$ngram -> text($isiDalam);
					my @gramIsi = $ngram->ngram($n);;
					
					# untuk setiap kata tergantung gramnya
					foreach my $gram (@gramIsi) {
						next if ($gram =~ /[\.|\?\*|\,]/);
						if ($hashKamusDua1g{$gram}) {
							$countFindDua++;
						}

						if ($hashKamusDua2g{$gram}) {
							$countFindDua++;
						}

						if ($hashKamusDua3g{$gram}) {
							$countFindDua++;
						}

						if ($hashkamusSatu1g{$gram}) {
							$countFindSatu++;
						}

						if ($hashKamusSatu2g{$gram}) {
							$countFindSatu++;
						}

						if ($hashKamusSatu3g{$gram}) {
							$countFindSatu++;
						}

						$countGram++;
					}

					$noSatu++;
					$noDua++;

					my $scoreSatu;
					my $scoreDua;

					# cek countGram agar tidak dibagi dengan 0
					if ($countGram==0) {
						$scoreSatu=0;
						$scoreDua=0;
					} else {
						$scoreSatu = $countFindSatu/$countGram;
						$scoreDua = $countFindDua/$countGram;
					}

					$bagianSatu="$bagianSatu $noSatu:$scoreSatu"; 
					$bagianDua="$bagianDua $noDua:$scoreDua";  
				}
				
			}

			print "$bagianSatu $bagianDua\n";	
			print OUT "$bagianSatu $bagianDua\n";	

		}
	}
	close OUT;
}


	