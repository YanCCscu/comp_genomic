#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: extract_longest_cds.pl
#
#        USAGE: ./extract_longest_cds.pl  
#
#  DESCRIPTION: This script use to extract longest CDS seq from human, mouse and other 
#  				have redundancy transcript of some gene.
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Liwujiao (), hnnd059@gmail.com
# ORGANIZATION: Sichuan Key Laboratory of Conservation Biology on Endangered Wildlife
#      VERSION: 1.0
#      CREATED: 04/21/2016 10:40:36 AM
#     REVISION: 2017.5.27 modified for ensemble > = 86
#===============================================================================

use strict;
use warnings;
use utf8;

die "perl $0 1|2|3 (1 for NCBI 2 for ensamble 3 for NCBI maker)<gff3> > uniq.id\n" if $#ARGV<1;
my (%gene,%tran,$g_id,$t_id,%tr_id,$pseudotrans);
my $num=$ARGV[0];
open(IN,"$ARGV[1]") or die "can not open $ARGV[1]\n";
while(<IN>){
	next if /^#/;
	chomp;
	if($num==1){
=head
		if(/\s+CDS\s+.*?GeneID:(\S+?),.*?protein_id=(\S+?)(;|$)/i){
			my @line=split/\t+/,$_;
                	my $len=$line[4]-$line[3]+1;	
			$tran{$2}=$1;
                	$gene{$1}{$2}+=$len;
		}
=cut
		if(/\s+mRNA\s+.*?ID=(\S+?);.*?GeneID:(\S+?),.*?Name=(\S+?);/){
                        $g_id=$2;
                        $t_id=$1;
                        $gene{$g_id}{$t_id}=0;
                        $tr_id{$t_id}=$3;

                }elsif(/\s+CDS\s+.+?ID=(\S+?);.*?Parent=(\S+?);.*?Name=(\S+?);/){
                        my @line=split/\s+/,$_;
                        my $len=$line[4]-$line[3]+1;
                        $tran{$2}=$3;
                        $gene{$g_id}{$2}+=$len;
                        print STDERR $g_id if !$gene{$g_id};
                }
	}elsif($num==2){
		if(/\s+pseudogenic_transcript\s+.+?ID=transcript:(\S+?);Parent=gene:(\S+?);.*?/){
			$pseudotrans=$1;
			print $pseudotrans;
		}
		next if /$pseudotrans/;
		if(/\s+transcript\s+.+?gene_id\s+"(\S+?)";.*?transcript_id\s+"(\S+?)"/){
			$g_id=$1;
			$t_id=$2;
			$gene{$g_id}{$t_id}=0;
#			print"$1\t$2\n";	
		}elsif(/\s+CDS\s+.*?transcript_id\s+"(\S+?)";.*?ccds_id\s+"(\S+?)"/){
			my @line=split/\s+/,$_;
			my $len=$line[4]-$line[3]+1;
			#print "$1\n",if($len==0);
			$tran{$1}="CDS:$1";
			$gene{$g_id}{$1}+=$len;
			print STDERR $g_id if !$gene{$g_id};
		}	
		if(/\s+transcript\s+.+?ID=(\S+?);Parent=(\S+?);Name=(\S+?)?biotype=protein_coding/){
			$g_id=$2;
			$t_id=$1;
			#print "$1\t$2\n";#exit;
			$gene{$g_id}{$t_id}=0;# store gene_id and transcript id
			$tr_id{$t_id}=$3;
			#$t_len=0; # reset transcript len
		}elsif(/\s+CDS\s+.+?ID=(\S+?);Parent=(\S+?);/){
			my @line=split/\s+/,$_;
			my $len=$line[4]-$line[3]+1;
			#print $2,"\n";exit;
			$tran{$2}=$1;
			$gene{$g_id}{$2}+=$len;# count CDS length
			print STDERR $g_id if !$gene{$g_id};
		}
		if(/\s+mRNA\s+.+?ID=transcript:(\S+?);Parent=gene:(\S+?);.*?biotype=protein_coding/){
			$g_id=$2;
                        $t_id=$1;
			#print "$g_id\t$t_id\n";
			$gene{$g_id}{$t_id}=0;			
		}elsif(/\s+CDS\s+.+?ID=CDS:(\S+?);Parent=transcript:(\S+?);/){
			my @line=split/\s+/,$_;
			my $len=$line[4]-$line[3]+1;
			$tran{$2}=$1;
			$gene{$g_id}{$2}+=$len;# count CDS length
			print STDERR $g_id if !$gene{$g_id};
		
		}
		
					
	}elsif($num==3){
		if(/\s+mRNA\s+.+?ID=RMA_00000434-RA;Parent=RMA_00000434;Name=RMA_00000434-RA;protein_coding/){
			
		}
		

	}
	
}
print "#Gene_id\tT_id\tProtein\tTranscript_id\tCDS_len\n",if($num==1);
print "#Gene_id\tTranscript_id\tProteinid\tCDS_len\n",if($num==2);
while(my ($k,$v)=each %gene){
	foreach my $key(sort { $v->{$b} <=> $v->{$a} } keys %$v){
		my @t=split /:/,$key;
		$tran{$key}=~s/CDS://g;
		#print "$k\t$t[-1]\t$tran{$key}\t$key\n",if(! $tr_id{$key});
		print "$k\t$t[-1]\t$tran{$key}\t$tr_id{$key}\t",$v->{$key},"\n",if($v->{$key}!=0 && $t[-1] && $num==1);
		print "$k\t$t[-1]\t$tran{$key}\t",$v->{$key},"\n",if($v->{$key}!=0 && $t[-1] && $num==2);
		#print "$k\t$key\t$tran{$key}\t$tr_id{$key}",$v->{$key},"\n",if(! $t[-1]);
		last;
	}
}
