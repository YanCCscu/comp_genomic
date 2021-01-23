#!/usr/bin/perl -w
use strict;
use File::Spec;
my $path_curf = File::Spec->rel2abs(__FILE__);
my ($vol, $dir, $file) = File::Spec->splitpath($path_curf);
if($#ARGV<1){
	print "example: perl $0 /pep/Results_Dec02/Orthogroups.csv pep/Results_Dec02/SingleCopyOrthogroups.txt pep/Results_Dec02/Orthogroups.GeneCount.csv\n";
	exit;
}
my $gene_table_all=$ARGV[0];
my $single_gene_id=$ARGV[1];
my $gene_count_all=$ARGV[2];
#print "head -n 1 $gene_table_all > $single_gene_id.name.csv\n/data/tools/genome_tools/fishInWinter.pl -bf table -ff table $single_gene_id $gene_table_all >> $single_gene_id.name.csv\n";
`head -n 1 $gene_table_all > $single_gene_id.name.txt`;
`$dir/fishInWinter.pl -bf table -ff table $single_gene_id $gene_table_all >> $single_gene_id.name.txt`;
`dos2unix $single_gene_id.name.txt`;
open IN1,"$single_gene_id.name.txt" or die "can not open $single_gene_id.name.txt\n";
open OUT_paml,">singlecopyGene.txt.paml" or die "can not open singlecopyGene.txt.paml\n";
my @sp;
my $i;
while(<IN1>){
	chomp;
	my @lines=split/\t/;
	my @out;
	if($.==1){
		@sp=@lines;	
	}else{  
		push @out,"$lines[0]";
		for(my $i=1;$i<=$#lines;$i++){
			$sp[$i]=~s/\.pep//;
			push @out,"$sp[$i]|$lines[$i]";
		}
		my $out1=join"\t",@out;
		print OUT_paml "$out1\n";
	}
}
close IN1;
close OUT_paml;
open IN2,"$gene_count_all" or die "can not open $gene_count_all\n";
open OUT_cafe,">Gene.table.cafe" or die "can not open Gene.table.cafe\n";
while(<IN2>){
	chomp;
	my @lines=split/\t/;
	my @out;
	if($.==1){
                @sp=@lines;     
                push @out,"famid\tfamid";
                for(my $i=1;$i<=$#lines-1;$i++){
                        $sp[$i]=~s/\.pep//;
                        push @out,$sp[$i];
                }
		my $out1=join"\t",@out;
		print OUT_cafe "$out1\n";
        }else{  
                my $out2=join"\t",$lines[0],@lines[0..$#lines-1];
                print OUT_cafe "$out2\n";
        }
}
close OUT_cafe;
close IN2;
