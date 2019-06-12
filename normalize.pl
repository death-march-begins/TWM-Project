use strict;
use File::Basename;

# Argumen
my $file = $ARGV[0];
if (! $file) {
  print "Cara jalankan: $0 <file>\n";
  exit;
}
# Ambil isi file
my $data = `cat $file`;
my @dicts = split /\n/, $data;

$file = basename($file); # Ambil nama file

my $max = 0;  # Deklarasi nilai maksimum
foreach my $dict (@dicts) {
	my ($freq, $word) = split /\t/, $dict;
	# cek nilai maksimum
	if ($freq > $max) {
		$max=$freq;
	}
}
# buat file sesuai dengan file yang diinput letakkan pada direktori normalize
open FILE, "> normalize/$file";
foreach my $dict (@dicts) {
	my ($freq, $word) = split /\t/, $dict;	
	my $norm= $freq/$max;
	print FILE "$freq\t$norm\t$word\n"; # isi dengan format frekuensi normalisasi kata
}