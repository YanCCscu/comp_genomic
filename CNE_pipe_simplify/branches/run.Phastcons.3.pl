#!/usr/bin/perl
#author: pcj 2019.10.9 finished.
# pcj fixed the bug in elements splited by CDS
use strict;
use warnings;
use Parallel::ForkManager;
use Getopt::Long;
use File::Basename;
use File::Spec;
my $path_curf = File::Spec->rel2abs(__FILE__);
my ($vol, $dir, $file) = File::Spec->splitpath($path_curf);
my($maf_dir,$seq_full_len);
my($seqname,%maf_seq);
my $prank_bin = '/data/nfs/OriginTools/bin';
GetOptions(
        "maf_dir|m:s"=>\$maf_dir,
        "help|?"=>\&USAGE,
        );
&USAGE,if(! $maf_dir);
#-------------------------------------------------------------
#main process
#-------------------------------------------------------------
opendir DIR,"$maf_dir" or die "can not open $maf_dir";
while(my $file=readdir DIR){
	next,unless($file=~/\.maf\.c$/);
	my $filemaf=$file;
	my $filemafc=$file;
	$filemaf=~s/\.c//;
#------store infor into dicts
	open MAF,"$maf_dir/$filemaf" or die "can not open $maf_dir/$filemaf\n";
	my %check_maf=();
	while(<MAF>){
		next,if/^#/;
		chomp;
		if(/^a score/){
			#print "$_\n";
			#s Tbai_Scaffold114          1784582 118 +  4312807 GGCCACCCTCCTCCGGGGGACTTCATCGCT
			my $seq1=<MAF>;
			my @line=split/\s+/,$seq1;
			$seq_full_len=$line[5];
			$seqname=$line[1];
			my $infor=join"=",($line[1],$line[2],$line[6]);
			my $len=length $line[6];
			my $end=$line[2]+$len-1;
			my $seq_end=$line[2]+$line[3]-1;
			my $ref_head=$line[1].'-'.$line[2].'-'.$seq_end.'-'.$end.'-'.$line[3];
			#print $ref_head," -> ",$infor," \@maf_seq\n"; 
			push @{$maf_seq{$ref_head}},$infor; #store headerkeys -> [ref species info seqname start seqend aligend length]
			$check_maf{$line[2]}=$ref_head;
			#print "|==",$line[2]," -> ",$ref_head," \@check_maf\n"; start -> headerkeys
			#print "$ARGV[2]\n";
			while($seq1=~/^s/){
				$seq1=<MAF>;
				chomp($seq1);
				my @line=split/\s+/,$seq1;
				#print "$seq1";
				my $infor=join"=",($line[1],$line[2],$line[6]) if ($seq1);
				#print "|__",$ref_head," -> ",$infor," \@maf_seq\n" if($seq1);
				push @{$maf_seq{$ref_head}},$infor if($seq1); #store ohter species info
			}
		}
	}
	%maf_seq=&check_maf(\%maf_seq,\%check_maf);
	close MAF;
	my @bed_filtered=&filtered_bed("CNE/$filemaf.c.con.bed.cname.bed.no.overlap","CNE/$filemaf.c.con.bed.cname.bed.overlap");
	print "###produce file to CNE/$filemaf.c.con.bed.cname.bed.final\n"; 
	open FBED,">CNE/$filemaf.c.con.bed.cname.bed.final" or die "can not open CNE/$filemaf.c.con.bed.cname.bed.final";
	print FBED join"\n",@bed_filtered if(@bed_filtered);
	print FBED"\n" if(@bed_filtered);
	&out_put_seq(\@bed_filtered,\%maf_seq,"$filemaf.c.con.bed.cname.bed.final");
}
#---------------------------------------
system("find ./GlopperID/ -name \"*.perglobleid\" | xargs cat  > all.perglobleid");
system("find ./LocalperID/ -name \"*.perlocalid\"| xargs cat  > all.perlocalid");

sub check_maf{ #merge blocks with no gaps 
	my $maf_seq=shift;
	my $check=shift;
	my $alen=keys %{$maf_seq};
	foreach(sort {$a<=>$b} keys %{$check}){
		my @heads1=split/\-/,${$check}{$_};
		my $h1=${$check}{$_};
		my $tag=$heads1[1]+$heads1[4]; #the end position+1
		my $base_len=$heads1[4];
		my @new_seq=();
		for(my $i=0;$i<=$#{${$maf_seq}{$h1}};$i++){
                	my @infor1=split/=/,${${$maf_seq}{$h1}}[$i];
                       	push @new_seq,$infor1[2];
                }

		while(exists ${$check}{$tag}){ ##end pos + 1 overlap with start position
			my @heads2=split/\-/,${$check}{$tag};
			my $h2=${$check}{$tag};
			$base_len+=$heads2[4];
			my $new_re_head=$heads1[0].'-'.$heads1[1].'-'.$heads2[2].'-'.$heads2[3].'-'.$base_len;
			print "concatenate ",$h2," and ",$h1," to ",$new_re_head," ... \n";
			for(my $i=0;$i<=$#{${$maf_seq}{$h1}};$i++){
				my @infor1=split/=/,${${$maf_seq}{$h1}}[$i];
				my @infor2=split/=/,${${$maf_seq}{$h2}}[$i];
				$new_seq[$i].=$infor2[2];
				my $new_infor=join"=",($infor1[0],$infor1[1],$new_seq[$i]);
				push @{${$maf_seq}{$new_re_head}},$new_infor;
			}
		        $tag+=$heads2[4];
		}
		
	}
	my $blen=keys %{$maf_seq};
	print "item number: ",$alen,"=>",$blen,"\n";
	return %{$maf_seq};
}
sub filtered_bed{
	my $bedfileno=shift;
	my $bedfile=shift;
	my @bed_filtered=();
	open BEDc,"$bedfileno" or die "can not open $bedfileno\n";
	while(<BEDc>){
		chomp;
		my @line=split/\t+/;
		my $len=$line[2]-$line[1];
		print "get no overlap items\n";
		push @bed_filtered,$_,if($len >= 30);
	}
	close BEDc;
	open BEDo,"$bedfile" or die "can not open $bedfile\n";
	while(<BEDo>){
                chomp;
                my @line=split/\t+/;
		if($line[1] >= $line[7] && $line[2] >= $line[8] && $line[1]<= $line[8]){
			my $newleft=$line[1]+$line[-1];
			$line[1]=$newleft;
			my $bed=join"\t",@line[0..3];
			my $len=$line[2]-$line[1];
			print "newleft: ",$bed;
                	push @bed_filtered,$bed,if($len >= 30); 
			
		}
		if($line[1] <= $line[7] && $line[2] <= $line[8] && $line[2] >= $line[7]){
			my $right=$line[2]-$line[-1];
                        $line[2]=$right;
                        my $bed=join"\t",@line[0..3];
                        my $len=$line[2]-$line[1];
			print "newright: ",$bed;
                        push @bed_filtered,$bed,if($len >= 30);

		}
		if($line[1] <= $line[7] && $line[2] >= $line[8]){
			my $newleft=$line[8]+1;
			my $newright=$line[7]-1;
			my $len1=$newright-$line[1];
			my $len2=$line[2]-$newleft;
			my $name1 = "$line[3]_1";
			my $name2 = "$line[3]_2";
			my $bed1=join"\t",($line[0],$line[1],$newright,$name1);
			my $bed2=join"\t",($line[0],$newleft,$line[2],$name2);
			print "Bnewright: ",$bed1;
			print "Bnewleft: ",$bed2;
			push @bed_filtered,$bed1,if($len1 >= 30);
			push @bed_filtered,$bed2,if($len2 >= 30);
		}
		if($line[1] >= $line[7] && $line[2] <= $line[8]){
			next;
		}
        }
	close BEDo;
	my %hash=();
	my @bed_filtered_nr = grep{++$hash{$_}<2} @bed_filtered;
	return @bed_filtered_nr;
}

sub out_put_seq{
	my ($bed,$maf_seq,$file)=@_;
	mkdir "Bed.fa/$file";
	foreach my $bed_line(@{$bed}){
		my @line=split/\t/,$bed_line;
		my $len=$line[2]-$line[1];
		my @names=split/\./,$line[3];
		my %nr=();
		@names=grep{++$nr{$_}<2} @names;
		my $fa_name=join"\.",@names;
		$line[3]=$fa_name;
		foreach my $seq(keys %{$maf_seq}){
			my @heads=split/\-/,$seq;
                	if($heads[0]=~/$line[0]/ && $line[1] >= $heads[1] && $line[1]-1 <= $heads[2] && $line[2]-1 <= $heads[2]){
                		open FA,">Bed.fa/$file/$fa_name.fa" or die "can not open >Bed.fa/$file/$fa_name.fa";
	#			print "open Bed.fa/$file/$line[3].fa\n";
				my @infor=split/=/,${$maf_seq{$seq}}[0];
				my $ref_seq=$infor[2];
				my @ref_seqbase=split"",$ref_seq;
				my $start=$line[1]-$heads[1];
				my $start_new = 0;
				my $base_count_start=0;
				my $base_count=0;
				my $ali_end=0;
				my $j=0;
				my $flag=0;
				for(my $i=0;$i<=$#ref_seqbase;$i++){
					if($base_count_start < $start && $ref_seqbase[$i] ne '-'){
						$base_count_start++;
					}
					if($base_count_start == $start){
						$start_new=$i+1;
						$flag=1;
						$j=$i;
						$base_count_start=$base_count_start+1;
						$i++;
					}
					if($base_count<$len && $flag == 1 && $ref_seqbase[$i] ne '-'){
						$base_count++;
					}
					if($base_count == $len){
						$ali_end=$i;
						last;
					}
				}
				if($ali_end == 0){
					mkdir "Join_fa/$file";
					open Join,">Join_fa/$file/$line[3].fa";
					print Join ">$infor[0]|$infor[1]|length:$len:bed:$line[1]:maf:$heads[1]-$heads[2]:base:$base_count,len:$len,ali:$ali_end\n";
					last;
				}
                        	foreach my $in(@{$maf_seq{$seq}}){
                        		my @infor=split/=/,$in;
					my $len_ali=$ali_end-$start_new+1;
                                	my $out_seq=substr($infor[2],$start_new,$len_ali);
                               		print FA">$infor[0]|$infor[1]|length:$len:ali:$len_ali\n$out_seq\n";
				}
                	}
      		}
		close FA;
		open IDLIST,">>IDlist.txt";
		open FINAL_BED,">>final.all.bed";
		$bed_line=join"\t",@line;
		print IDLIST "$fa_name\n";
		print FINAL_BED "$bed_line\n";
		&getperID("Bed.fa/$file/$fa_name.fa",$prank_bin,$dir),if(-e "Bed.fa/$file/$fa_name.fa");
		if(! -e "Bed.fa/$file/$fa_name.fa"){
			mkdir "Join_fa/$file"; 
			open Join,">Join_fa/$file/$fa_name.fa";
		}
	}
	
}

sub getperID{
	my $file=shift;
	my $prank_bin=shift;
	my $dir=shift;
	system("perl $dir/getperID.pl $file $prank_bin/prank");
	system("cp $file.perglobleid ./GlopperID");
	system("cp $file.perlocalid ./LocalperID");
}

######################################print usage
sub USAGE{
    my $usage=<<"USAGE";
Name:
    $0  
Description:
	#author: pcj 2019.10.9 finished.
Usage:
    options:
    --maf_dir|-m       <string>  path for maf files dir 
    --help|-h           	print this information 
Example:
perl $0 -m splitmaf 
USAGE
   print $usage;
   exit;
}

