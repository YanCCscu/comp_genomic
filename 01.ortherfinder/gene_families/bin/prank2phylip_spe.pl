#!/usr/bin/perl
use strict;
# Usage : This script use to reform the prank fsta aligment to phylip input, which only keep specie as name,will chop the gene name!
die "perl $0 <prank> <out.phylip>\n" if $#ARGV<1;
my $prank_file=shift;
my $phylip_out=shift;

open IN,$prank_file or die "can not open $prank_file $!";

my %cds=();
$/=">";
while(<IN>){
	chomp;
	next,until($_);
	my @lines=split/\n/;	
	my $title=$lines[0];
	my $id=$1 if($title=~/^(\S+?)\|/);
	my $seq=join"",@lines[1..$#lines];
	$cds{$id}=$seq;
}
close IN;
$/="\n";
open  OUT,">$phylip_out" or die "$!";
my $num=keys %cds;
my $len;
my $n=1;
for my $gene(keys %cds){
	my $str=$cds{$gene};
	$len=length $str if($n==1);
	print OUT "$num  $len\n" if($n==1);
	$n++;
	print OUT "$gene  $str\n";
}
close OUT;
open IN,

