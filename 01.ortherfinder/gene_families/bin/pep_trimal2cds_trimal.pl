#!/usr/bin/perl-w
use strict;
use Data::Dumper;
die "perl $0 <CDS> <pep_prank> <pep_html>\n" unless ($#ARGV==2);
my $cds=shift;
my $pep_prank=shift;
my $pep_html=shift;

my %cds=read_fasta($cds);
my %pep_prank=read_fasta($pep_prank);


open IN,$pep_html or die  "$!";
my %select_loci;
my $id=0;
while(<IN>){
	next unless (/Selected Cols/);
	chomp;
	my @f=split(/\=|\>/,$_);
	my @e;
	for(my $i=0;$i<=$#f;$i++){
		if($f[$i]=~/sel/){
			$select_loci{$id}=$f[$i];
			$id++;
		}
	}
}
close IN;

foreach my $gene_id(keys %pep_prank){
	my $cds_seq=$cds{$gene_id};
	my $pep_seq=$pep_prank{$gene_id};
	my $len=length $pep_seq;
	die  "err at $gene_id\tlen_seq: $len\tlen_loci\t$id\n" unless ($id eq $len );
	print ">$gene_id\n";
	my $out;
	my $j=0;
	for(my $i=0;$i<$len;$i++){
		my $pep_base=substr($pep_seq,$i,1);
#		next if($pep_base eq '-');
		if (  ($select_loci{$i} eq 'sel' && $pep_base eq '-' ) or ($select_loci{$i} eq 'sel' && $pep_base eq "X") or ($select_loci{$i} eq 'sel' && $pep_base eq "U") ){
			$out.='---';
			$j+=3 if $pep_base ne '-';
		}
		if($select_loci{$i} eq 'sel' && $pep_base ne '-' && $pep_base ne "X" && $pep_base ne "U"){
			$out.=substr($cds_seq,$j,3);
			$j+=3;
		}
		if($select_loci{$i} eq 'nsel' && $pep_base ne '-'){
			$j+=3;
		}
	}
	print  fasta_seq($out);
}


sub fasta_seq{
        my $cds_seq=shift;
        my $c;
        my $length_seq=length $cds_seq;
        for(my $i=0;$i<$length_seq;$i+=60){
                $c.=substr($cds_seq,$i,60)."\n";
        }
        return $c;
}


sub read_fasta{
	my $file=shift;
	my %p;
	open IN,$file or die "Fail $file:$!";
        $/=">";
        while(<IN>){
		chomp;
		next,unless($_);
		my @lines=split/\n/;
                my ($id,$seq);
                if ($lines[0]=~/^(\S+)/){
                        $id=$1;
                }else{
                        die "No access number found in header line of fasta file:$file!\n";
		}
                $seq=join"",@lines[1..$#lines];
                $seq=~s/\s//g;
                $p{$id}=$seq;
        }
        close IN;
	$/="\n";
	return %p;
}
