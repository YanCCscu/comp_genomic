#!/usr/bin/perl -w
#author pcj 2020.3.20 finished
use strict;

if($#ARGV<0){
	print "example: perl $0 ST,SS infasta best.tree\n";
	print "\033[1;91mnote: seq name should be consistant with species node name of the tree\n";
	print "note: Target sp: ST,SS \n";
	print "note: PEP.fas: gene_pep (aligned) \n";
	exit;
}
my @target=split",",$ARGV[0];
`rm covergence.results.out` if(-e "covergence.results.out");
open OUT,">covergence.results.out" or die "can not open results.out\n";
#opendir GENE_PEP,"$ARGV[1]" or die "can not open $ARGV[1]";
my $fa_file=$ARGV[1];
system("/data/nfs/OriginTools/phylogeny_evolution/iqtree-1.6.8-Linux/bin/iqtree -quiet -safe -redo -s $fa_file -m JTT+R4 -asr -te $ARGV[2].nodes") and print STDERR "can not execute /data/nfs/OriginTools/phylogeny_evolution/iqtree-1.6.8-Linux/bin/iqtree -quiet -safe -redo -s $fa_file -m JTT+R4 -asr -te $ARGV[2].nodes \n";
#print "$node_anc\n";
my %ancenstor;
	if(-e "$fa_file.state"){
		open STATE,"$fa_file.state" or die "can not open $fa_file.state\n";
		while(<STATE>){
			chomp;
			my @line=split/\t/;
			my $tar_num=0;
			foreach my $tar(@target){
				if($line[0]=~/$tar/){
					$tar_num++;	
				}
			}
			push @{$ancenstor{$line[0]}},$line[2] if($tar_num==@target);
		}
		my @nodes=keys %ancenstor;
		my $ancenstor_near=&sort_len(@nodes);
		print "$ancenstor_near--\n";	
		my %matrix=();
		my $len=();
		open FA,"$fa_file" or die "can not open $fa_file\n";
		$/=">";
		while(<FA>){
			chomp;
			next,unless($_);
        		my @line=split/\n/;
			if($#line<1){
				print "error ! $fa_file\n";
				exit;
			}
			my $names=$line[0];
			$names=~s/\s+//g;
	#print "$names--$fa_file\n";
        		my $seq=join"",@line[1..$#line];
        		my @aas=split"",$seq;
        		push @{$matrix{$names}}, @aas;
        		$len=$#aas;
		}
		my @all=keys %matrix;
		my %target=map{$_=>1} @target;
		my %all=map{$_=>1} @all;
		my @others=grep{!$target{$_}} @all;
		my @out=();
		$/="\n";
		for my $i (0..$len){
			my %count=();
			my %count1=();
			my @tar_po=();
			my @other_po=();
			foreach my $tar (@target){
			#print "$tar\t${$matrix{$tar}}[$i]\n";
				push @tar_po,${$matrix{$tar}}[$i];
			}
			my @tar_po_num=grep{++$count{$_}<2} @tar_po;
			my $flag=0;
			foreach my $other (@others){
				#print "$other\n";
				$flag=1 if(${$matrix{$other}}[$i] eq ${$matrix{$target[0]}}[$i]);
				push @other_po,${$matrix{$other}}[$i];
			}
			my $position=$i+1;
			my @other_po_num=grep{++$count1{$_}<2} @other_po;
			push @out,"$position\tconvergence1\t${$matrix{$others[0]}}[$i]->${$matrix{$target[0]}}[$i]" if($flag==0 && $#tar_po_num==0 && $#other_po_num==0 && ${$matrix{$others[0]}}[$i] eq ${$ancenstor{$ancenstor_near}}[$i]);	
			push @out,"$position\t parallel\t${$matrix{$others[0]}}[$i]->${$matrix{$target[0]}}[$i]" if($flag==0 && $#tar_po_num==0 && $#other_po_num==0 && ${$matrix{$others[0]}}[$i] ne ${$ancenstor{$ancenstor_near}}[$i] && ${$matrix{$target[0]}}[$i] ne ${$ancenstor{$ancenstor_near}}[$i] );
			push @out,"$position\t convergence2\t${$matrix{$others[0]}}[$i]->${$matrix{$target[0]}}[$i]" if($flag==0 && $#tar_po_num==0 && $#other_po_num==0 && ${$matrix{$target[0]}}[$i] eq ${$ancenstor{$ancenstor_near}}[$i] );
		}
		my $ancenstor_seq=join"",@{$ancenstor{$ancenstor_near}};
		print OUT"$fa_file\t",join"\t",@out,"$ancenstor_seq","\n" if(@out);
	
	}

sub sort_len{
	my @a=@_;
	my %hash;
	foreach(@a){
		$hash{$_}=length($_);			
	}
	foreach(sort{$hash{$a}<=>$hash{$b}} keys %hash){
		return $_;
		exit;
	}	
}
