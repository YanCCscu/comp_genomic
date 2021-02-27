#!/usr/bin/perl
use strict;
use warnings;
if($#ARGV < 0){
	print "$0 \"*.maf\"\n";
	exit; 
}
my @maf_files=glob"$ARGV[0]";
my %seqs;
foreach(@maf_files){
	open MAF,"$_" or die "can not open $_\n";
	while(<MAF>){
		next,unless(/^s\s+/);
		chomp;	
		my @lines = split/\s+/;
		my @names = split/_/,$lines[1];
		
		$seqs{$names[0]}.=$lines[6];
	}	
}
foreach(keys %seqs){
	my $out_seq=&format_seq($seqs{$_});
	print">$_\n$out_seq\n";
}
sub format_seq{
	my $seq = shift;
	my $length = length $seq;
	my $left_num = $length % 50; 
	my @seqs = $seq =~/.{50}/g;
	my $out = join"\n",@seqs;
	my $left_seq = substr($seq,$length-$left_num,$left_num);
	$out = $out."\n$left_seq";
	return "$out";
}
