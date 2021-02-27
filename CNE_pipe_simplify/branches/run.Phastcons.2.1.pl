#!/usr/bin/perl
#author: pcj 2019.10.9 finished.
# pcj fixed the bugs about the CDS interrupted CNEs and the exact aligned length 2019.10.30.
# pcj updated the pipeline by adding the GERP program 2019.12.11. now version 2.0.
# pcj added the mutiple_threads_GERP package to use mutiple threads when run GERP now version 2.1 .
# pcj fixed the bug in elements splited by CDS
use strict;
use warnings;
use Parallel::ForkManager;
use Getopt::Long;
use File::Basename;
use File::Spec;
use lib dirname(__FILE__) . "/packages/";
use mutiple_threads_GERP;
my $path_curf = File::Spec->rel2abs(__FILE__);
my ($vol, $dir, $file) = File::Spec->splitpath($path_curf);
my $max_process=4;
my $cpu_total=20;
my($phast_bin,$maf_dir,$bed_tools_bin,$prank_bin,$tree,$cds_gff,$ref_species,$seq_full_len);
GetOptions(
        "phast_bin|ph:s"=>\$phast_bin,
        "maf_dir|m:s"=>\$maf_dir,
        "bed_tools_bin|b:s"=>\$bed_tools_bin,
	"prank_bin|pr:s"=>\$prank_bin,
	"threads|th:i"=>\$max_process,
	"cpu_total|ct:i"=>\$cpu_total,
	"tree|tr:s"=>\$tree,
	"cds_gff|cd:s"=>\$cds_gff,
	"ref_species|re:s"=>\$ref_species,
        #"q!"=>\$sge,
        #        #"l!"=>\$local,
        "help|?"=>\&USAGE,
        );
&USAGE,if(!$phast_bin || ! $maf_dir || ! $bed_tools_bin);
print "thread: $max_process\n";
#my $cpu_total=`grep 'physical id' /proc/cpuinfo |wc -l`;
#chomp($cpu_total);
#$cpu_total=int($cpu_total);
my $pm = new Parallel::ForkManager($max_process);
my($seqname,%maf_seq);
#-------------------------------------------------------------
#clear files in last running ...
#-------------------------------------------------------------
my @dirs=qw(CNE Bed.fa Join_fa LocalperID GlopperID mod GERP);
foreach (@dirs){
	if(-e $_){
		`rm -rf  $_`;
		mkdir $_;
	}else{
		mkdir $_;
	}
}
unlink "IDlist.txt",if(-e "IDlist.txt");
unlink "final.all.bed",if(-e "final.all.bed");
#-------------------------------------------------------------
#main process
#-------------------------------------------------------------
opendir DIR,"$maf_dir" or die "can not open $maf_dir";
LINE:
while(my $file=readdir DIR){
	next,unless($file=~/\.maf\.c$/);
	$pm->start and next LINE;
	my $filemaf=$file;
	my $filemafc=$file;
	$filemaf=~s/\.c//;
	print "$phast_bin/phyloFit --tree $tree --msa-format MAF --out-root ./mod/phyloFit.$file --subst-mod REV --EM --precision HIGH -l ./mod/$file.phyloFit.log $maf_dir/$file\n";
	system("$phast_bin/phyloFit --tree $tree --msa-format MAF --out-root ./mod/phyloFit.$file --subst-mod REV --EM --precision HIGH -l ./mod/$file.phyloFit.log $maf_dir/$file");
	print "$phast_bin/phastCons --expected-length 45 --target-coverage 0.3 --rho 0.3 --most-conserved ./CNE/$file.c.con.bed --log ./CNE/$file.phastCons.log  $maf_dir/$file ./mod/phyloFit.$file.mod > ./CNE/$file.c.score.wig\n";
	system("$phast_bin/phastCons --expected-length 45 --target-coverage 0.3 --rho 0.3 --most-conserved ./CNE/$file.c.con.bed --log ./CNE/$file.phastCons.log  $maf_dir/$file ./mod/phyloFit.$file.mod > ./CNE/$file.c.score.wig");
#=head disabled by pcj 2019.4.22

#------store infor into dicts
	open BED,"./CNE/$file.c.con.bed" or die "can not open ./CNE/$file.c.con.bed \n";
	open MAF,"$maf_dir/$filemaf" or die "can not open $maf_dir/$filemaf\n";
	my %check_maf=();
	while(<MAF>){
		next,if/^#/;
		chomp;
		if(/^a score/){
			#print "$_\n";
			my $seq1=<MAF>;
			my @line=split/\s+/,$seq1;
			$seq_full_len=$line[5];
			$seqname=$line[1];
			my $infor=join"=",($line[1],$line[2],$line[6]);
			my $len=length $line[6];
			my $end=$line[2]+$len-1;
			my $seq_end=$line[2]+$line[3]-1;
			my $ref_head=$line[1].'-'.$line[2].'-'.$seq_end.'-'.$end.'-'.$line[3];
			push @{$maf_seq{$ref_head}},$infor;
			$check_maf{$line[2]}=$ref_head;
			#print "$ARGV[2]\n";
			while($seq1=~/^s/){
				$seq1=<MAF>;
				chomp($seq1);
				my @line=split/\s+/,$seq1;
				#print "$seq1";
				my $infor=join"=",($line[1],$line[2],$line[6]) if ($seq1);
				push @{$maf_seq{$ref_head}},$infor if($seq1);
			}
		}
	}
	%maf_seq=&check_maf(\%maf_seq,\%check_maf);
	close MAF;
	chdir "GERP"; 
	`cp $maf_dir/$file ./`;
#--------split maf into blocks
	open IN_MAF,"$file" or die "can not open $file\n";
	$/="a score";
	my $line=0;
	my %block=();
	while(<IN_MAF>){
		chomp;
		my $i =$.-1;
		open OUT,">$file.block$i.mfa" if $i>0;
		if($.==1){
			$line=$_;
		}else{
			my @lines=split/\s+/,$_;
			$block{"block$i"}=$lines[3];	
			print OUT"${line}a score$_";
		}
	}
	$/="\n";
	close IN_MAF;

	my $id=$1,if($filemaf=~/(\d+\.maf)/);
	mutiple_threads_GERP::block_file_deal($file,$tree,$id,$seqname,$ref_species,\%block,$max_process,$cpu_total) ; # added by pcj to use mutiple threads when run GERP.
	chdir "../";
	open OUT_phastCons,">./CNE/$file.c.con.bed.cname.phas.bed" or die "can not open ./CNE/$file.c.con.bed.cname.phas.bed !\n";
	while(<BED>){
		chomp;
		my @line=split/\t+/;
		$_=~s/$line[0]/$seqname/;
		$_=~s/$filemaf\.(\S+)/$id\.phas.$1/;
		print  OUT_phastCons "$_\n";
	}
	close BED;
	close OUT_phastCons;
	system("cat ./CNE/$file.c.con.bed.cname.phas.bed ./CNE/$file.c.con.bed.cname.GERP.bed > ./CNE/$file.c.con.bed.cname.bed.phas-GERP.bed");
	system("sort -k1,1 -k2,2n ./CNE/$file.c.con.bed.cname.bed.phas-GERP.bed > ./CNE/$file.c.con.bed.cname.bed.phas-GERP.sorted.bed");
	system("$bed_tools_bin/bedtools merge -i ./CNE/$file.c.con.bed.cname.bed.phas-GERP.sorted.bed -d 10 -c 4 -o collapse > ./CNE/$file.c.con.bed.cname.bed");
	system("perl -i -p -ne 's/,/_/g' ./CNE/$file.c.con.bed.cname.bed");
	system("$bed_tools_bin/bedtools intersect -wo -a ./CNE/$file.c.con.bed.cname.bed -b $cds_gff > ./CNE/$file.c.con.bed.cname.bed.overlap");
	system("$bed_tools_bin/bedtools intersect -v -a ./CNE/$file.c.con.bed.cname.bed -b $cds_gff > ./CNE/$file.c.con.bed.cname.bed.no.overlap");
	my @bed_filtered=&filtered_bed("./CNE/$file.c.con.bed.cname.bed.no.overlap","./CNE/$file.c.con.bed.cname.bed.overlap");
	open FBED,">./CNE/$file.c.con.bed.cname.bed.final" or die "can not open ./CNE/$file.c.con.bed.cname.bed.final";
	print FBED join"\n",@bed_filtered if(@bed_filtered);
	print FBED"\n" if(@bed_filtered);
	&out_put_seq(\@bed_filtered,\%maf_seq,"$file.c.con.bed.cname.bed.final");
	$pm->finish;
}
$pm->wait_all_children;
#---------------------------------------

sub check_maf{
	my $maf_seq=shift;
	my $check=shift;
	foreach(sort {$a<=>$b} keys %{$check}){
		my @heads1=split/\-/,${$check}{$_};
		my $h1=${$check}{$_};
		my $tag=$heads1[1]+$heads1[4];
		my $base_len=$heads1[4];
		my @new_seq=();
		for(my $i=0;$i<=$#{${$maf_seq}{$h1}};$i++){
                	my @infor1=split/=/,${${$maf_seq}{$h1}}[$i];
                       	push @new_seq,$infor1[2];
                }

		while(exists ${$check}{$tag}){
			my @heads2=split/\-/,${$check}{$tag};
			my $h2=${$check}{$tag};
			$base_len+=$heads2[4];
			my $new_re_head=$heads1[0].'-'.$heads1[1].'-'.$heads2[2].'-'.$heads2[3].'-'.$base_len;
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
                	push @bed_filtered,$bed,if($len >= 30); 
			
		}
		if($line[1] <= $line[7] && $line[2] <= $line[8] && $line[2] >= $line[7]){
			my $right=$line[2]-$line[-1];
                        $line[2]=$right;
                        my $bed=join"\t",@line[0..3];
                        my $len=$line[2]-$line[1];
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
system("find ./GlopperID/ -name \"*.perglobleid\" | xargs cat  > all.perglobleid");
system("find ./LocalperID/ -name \"*.perlocalid\"| xargs cat  > all.perlocalid");

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
	## pcj fixed the bugs about the CDS interrupted CNEs and the exact aligned length 2019.10.30.
	## pcj updated the pipeline by adding the GERP program 2019.12.11. now version 2.0.
	## pcj added the mutiple_threads_GERP package to use mutiple threads when run GERP. Now version 2.1 2019.12.30.
	This script is to run phast and GERP to indentify the conserved elements in mutiple genome alignments;
Usage:
    options:
    --phast_bin|-ph     <string>	path for phast/bin
    --maf_dir|-m       <string>  path for maf files dir 
    --bed_tools_bin|-b <string>	path for bedtools dir
    --prank|pr	      <string>	path for prank bin dir
    --threads|-th       <int>	number of threads (defaut: 4)	   
    --cpu_total|-ct     <int>	max cpu(threads) used for scripts, should be bigger than -th (defaut: 20)	   
    --tree|tr	      <string>	the tree file in nex format
    --cds_gff|-cd      <string>	the cds gff file of refference genome. should has the same reference genome seqnames as in maf files. 
    --help|-h           	print this information 
    --re_species|-re   <string> the reference species
Example:
perl $0 -ph /data/tools/call_CNE_new/phast-1.3/bin/ -m /data/project/sea_snake/call_CNE/multiz_maf/maf/test.maf -b /data/tools/call_CNE_new/bedtools2/bin/ -th 10 -pr /data/tools/prank-msa/bin/ -tr 10species.contree.nex -cd /data/nfs/ww/00_Frog/01_CNEs/02_frog_fish/08_get_cne/maf/maf/fish.cds.gff -re Acar
USAGE
   print $usage;
   exit;
}

