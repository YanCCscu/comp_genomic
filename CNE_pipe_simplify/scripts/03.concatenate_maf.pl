#!/usr/bin/perl
use File::Spec;
my $path_curf = File::Spec->rel2abs(__FILE__);
my ($vol, $dir, $file) = File::Spec->splitpath($path_curf); 
#author: pcj 2019.10.9 finished.
use strict;
if($#ARGV <0){
	print "example: perl $0 10species.contree.nex Acar 5(number of maf files for each species) all_maf_dir \n";
	exit;
} 
#nw_prune -v -f /data/backup/yancc/data/psgconv/species.tre spelist >CNE.tre
my $tree=$ARGV[0];
my $reference=$ARGV[1];
my $split_num=$ARGV[2];
my $AllMAF=$ARGV[3];
my $pathtomultiz=$dir."multiz/bin/multiz";
system("Rscript $dir/parse_tree.R $tree");
open NODES,"${tree}.cnodes" or die "can not open ${tree}.cnodes\n";
my($name1,$name2);
chomp (my @names=<NODES>);
my ($name3,$name3_1);
if($names[1] ne "$reference"){
	$name3="$reference-$names[0]-$names[1]";
	$name3_1="$reference-$names[0]-$names[1]";
}
if($names[1] eq "$reference"){	
	$name3="$reference-$names[0]-$names[2]";
	$name3_1="$reference-$names[0]-$names[2]";
}
my %command;
for(my $i=1;$i<=$split_num;$i++){
	push @{$command{$i}}," $pathtomultiz $AllMAF/$reference.$names[0].$i.net.filtered.axt.maf  $AllMAF/$reference.$names[1].$i.net.filtered.axt.maf 1 > $AllMAF/$name3.$i.net.filtered.axt.maf \n" if($names[0] ne "$reference" && $names[1] ne "$reference");
	push @{$command{$i}}," $pathtomultiz $AllMAF/$reference.$names[0].$i.net.filtered.axt.maf  $AllMAF/$reference.$names[2].$i.net.filtered.axt.maf 1 > $AllMAF/$name3.$i.net.filtered.axt.maf \n" if($names[0] ne "$reference" && $names[1] eq "$reference" && $names[2] ne "$reference");
}
#=head
if($names[1] ne "$reference"){
	for (my $i=2;$i<=$#names;$i++){
		next unless($names[$i] ne "$reference");
		$name3_1.="-$names[$i]";
		for (my $j=1;$j<=$split_num;$j++){
			push @{$command{$j}},"$pathtomultiz $AllMAF/$name3.${j}.net.filtered.axt.maf  $AllMAF/$reference.$names[$i].${j}.net.filtered.axt.maf 1 > $AllMAF/$name3_1.${j}.net.filtered.axt.maf \n"if($names[$i] ne "$reference");
		}
		$name3=$name3_1;	
	}
}else{
	for (my $i=3;$i<=$#names;$i++){
		next unless($names[$i] ne "$reference");
		$name3_1.="-$names[$i]";
		for (my $j=1;$j<=$split_num;$j++){
			push @{$command{$j}},"$pathtomultiz $AllMAF/$name3.${j}.net.filtered.axt.maf  $AllMAF/$reference.$names[$i].${j}.net.filtered.axt.maf 1 > $AllMAF/$name3_1.${j}.net.filtered.axt.maf \n"if($names[$i] ne "$reference");
		}
		$name3=$name3_1;
	}
}
foreach (sort {$a<=>$b}keys %command){
	print " @{$command{$_}}";
}
