#!usr/bin/perl
use warnings;
use strict;
use WWW::Mechanize;

# Argumen crawling-link.pl
my $n = $ARGV[0];
# Validasi Argumen
my $dieArgv="Mohon ikuti contoh dibawah\nex: perl $0 banyak_iterasi\n";

if (not defined $n) {
  die $dieArgv;
}

# buat objek dan inisialisasi User Agent
my $initial_user_agent = 'Windows; U; Windows NT 6.1; nl; rv:1.9.2.13) Gecko/20101203 Firefox/3.6.13';
my $mech = WWW::Mechanize->new(agent => $initial_user_agent);

# Deklarasi variabel
my $category = "neurology";
my $PATH = "url";
my $filename= "url-$category-chapter.txt";
my %urls;
my @links;

# Dapatkan URL dengan machanize berdasarkan tanggal
my $i=1;
while ($i <= $n) {

  print "Mendapatkan Url $category Page $i\n";

  # $mech->get("https://link.springer.com/search/page/$i?facet-discipline=%22Medicine+%26+Public+Health%22&facet-sub-discipline=%22Oncology%22&facet-language=%22En%22&facet-content-type=ConferencePaper");
  $mech->get("https://link.springer.com/search/page/$i?facet-discipline=%22Medicine+%26+Public+Health%22&facet-sub-discipline=%22Neurology%22&facet-language=%22En%22&facet-content-type=%22Chapter%22");

 
  # masukan URL yang didapat kedalam array links
  @links = $mech->links(); 

  # Masukan URL artikel kedalam hash
  foreach my $link (@links) {
    my $url = $link->url;
    if ($url=~ /-/ && $url=~ /chapter/) {   # cek URL
      $urls{$url} =1;           
    }
  }
  $i++;
}    

# Buat dab buka file output
open(my $fh, '>', "$PATH/$filename");

# Tulis URL yang sudah di hash kedalam file 
$i=1;
foreach my $url (keys %urls) {
  print "\n";
  print "Nama File : $category-$i.html \nUrl : $url\n";
  print $fh "$category-$i.html https://link.springer.com$url\n";
  print "\n";
  $i++;
}

# Tutup file dan selesai
close $fh;
print "Selesai\nTotal Url : ".($i-1);
print "\n";