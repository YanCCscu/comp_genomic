#!/usr/bin/perl

=head1 Name

 obtain_4d.pl

=head1 Description

 obtain 4d site from the fasta-format sequence file.

=head1 Version

 Original from: Bo li, libo@genomics.org.cn
 Modified by: Guang Xuanmin, guangxuanmin@genomics.org.cn
 Version: 1.0,  Date: 2010-9-30
 Modified to use fasta-farmat as input sequence file. 2017.12.19

=head1 Usage

 perl obtain_4d.pl [options] <in.fasta> 
  --dir <str>       directory for output, default ./

=head1 Example
 
 perl bin/obtain_4d.pl all.fasta --dir out/

=cut

use strict;
use Getopt::Long;
use FindBin qw($Bin);

my $dir;
GetOptions(
    "dir:s" => \$dir
);

$dir ||= ".";
$dir =~ s/\/$//;
die `pod2text $0` if (@ARGV != 1);
mkdir $dir if (!-e $dir);

my $phy_file  = shift;
my @slashes   = split /\//, $phy_file;
my $file_name = $slashes[-1];

## Extract 4d sites;
my $file_4d = &extract_4dsite_from_phy($phy_file, "$dir/$file_name");

sub extract_4dsite_from_phy {
	my $file     = shift;
	my $aim_file = shift;

	my %codons = (
		'CTT' => 'L', 'CTC' => 'L', 'CTA' => 'L', 'CTG' => 'L',
		'GTT' => 'V', 'GTC' => 'V', 'GTA' => 'V', 'GTG' => 'V',
		'TCT' => 'S', 'TCC' => 'S', 'TCA' => 'S', 'TCG' => 'S',
		'CCT' => 'P', 'CCC' => 'P', 'CCA' => 'P', 'CCG' => 'P',
		'ACT' => 'T', 'ACC' => 'T', 'ACA' => 'T', 'ACG' => 'T',
		'GCT' => 'A', 'GCC' => 'A', 'GCA' => 'A', 'GCG' => 'A',
		'CGT' => 'R', 'CGC' => 'R', 'CGA' => 'R', 'CGG' => 'R',
		'GGT' => 'G', 'GGC' => 'G', 'GGA' => 'G', 'GGG' => 'G'
	);
	my $i = 0;
	my ($num_species, $length_seq);
	my (@seq,         @name);
	open IN, $file or die "fail to open $file\n";
	my $cycle=0;
	while (<IN>) {
		chomp;
		if (/^>/) {
			$i++ if $cycle != 0;
			$_=~s/^>//;
			$name[$i] = $_;
		} else {
			$seq[$i] .= $_;
		}
		$cycle++;
	}
	$num_species = @name;
	$length_seq = length $seq[$i];
	close IN;

	my @out;
	for (my $j = 0 ; $j < $length_seq ; $j += 3) {
		my @codon  = ();
		my @site   = ();
		my @first2 = ();
		my $permi  = "y";
		for (my $i = 0 ; $i < $num_species ; $i++) {
			$codon[$i]  = uc(substr($seq[$i], $j,     3));
			#print "$codons{ $codon[$i] }\n";
			$site[$i]   = uc(substr($seq[$i], $j + 2, 1));
			$first2[$i] = uc(substr($seq[$i], $j,     2));
#			print "$i\t$first2[$i]\t$first2[ $i - 1 ]\n";
			if ($i > 0 and $first2[$i] ne $first2[ $i - 1 ]) {
				$permi = "n";
				last;
			}
			if (!exists $codons{ $codon[$i] }) {
				$permi = "n";
				last;
			}
		}
		#print "$codons{ $codon[$i]}\t$permi\t$i\t$first2[$i]\t$first2[ $i - 1 ]\n";
		if ($permi eq "y") {
			for ($i = 0 ; $i < $num_species ; $i++) {
				$out[$i] .= $site[$i];
			}
		}
	}
	my $length = length $out[0];
	open OUT, ">$aim_file.4d" or die;
	print OUT "   $num_species   $length\n";
	for (my $i = 0 ; $i < $num_species ; $i++) {
		printf OUT "%-9s", $name[$i];
		print OUT " $out[$i]\n";
	}
	close OUT;
	"$aim_file.4d";
}

