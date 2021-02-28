#!/usr/bin/perl 
use strict;
use warnings;
use File::Spec;
my $path_curf = File::Spec->rel2abs(__FILE__);
my ($vol, $dir, $file) = File::Spec->splitpath($path_curf);
my $maffas=$ARGV[0];
my $prank="/data/nfs/OriginTools/bin/prank";
##### run prank #####
print "\@run prank ... $prank -d=$maffas -o=$maffas -showtree -showanc -keep -prunetree -seed=10 ...\n";
`$prank -d=$maffas -o=$maffas -showtree -showanc -keep -prunetree -seed=10  `;

#### parse tree ####
`Rscript $dir/parse_tree.R $maffas.anc.dnd`;
`cat $maffas.anc.dnd.* > $maffas.alltree_infor`;
#### hash fasta #####
print "read in $maffas.anc.fas ... \n";
open FA,"$maffas.anc.fas" or die "can not open $maffas.anc.fas";
my %hash_fa;
$/=">";
while(<FA>){
	chomp;
	next,unless($_);
	my @line=split/\n/;
	my $head=$1,if($line[0]=~/(^\S+)/);
	$head=~s/^(\S+?)_.*/$1/g;
	my $seq=join"",@line[1..$#line];
	$hash_fa{$head}=$seq;
}
$/="\n";
close FA;
##### struct tree hash ####
my %parents_edge=();
my %edges_tag=();
my @children=();
my @parents=();
print "read in $maffas.alltree_infor ... \n";
open TREE_INFOR,"$maffas.alltree_infor" or die "can not open $maffas.alltree_infor\n";
while(<TREE_INFOR>){
	chomp;
	my @line=split/\t/;
	if($_=~/^\d/){
		$parents_edge{$line[0]}.=$line[1].'-';
	}
	if($_=~/^[A-Z]/){
		$line[0]=~s/(\S+?)_.*/$1/g;
		push @children,$line[0];
	#	print "$_++\n";	
	}
	if($_=~/^#/){
		push @parents,$line[0];
		
	}
}
close TREE_INFOR;
@children=sort @children;
my $number_child=scalar @children;
my $i=0;
#=cut
my %parents_tag=();
my ($id1,$id2);
print `nw_display $maffas.anc.dnd`;
%parents_tag=&get_parent_tag("$maffas.anc.dnd");
print "---------------------------------------------\n";
#foreach (keys %parents_tag){
#	print "$_:$parents_tag{$_}\n";
#}
print "---------------------------------------------\n";

#print "$number_child====\n";
#my $a=keys %parents_edge;
#print "$a\n";
#print "$_\n" for @parents;
#=cut
open PERIDLOCAL,">$maffas.perlocalid";
open ALLPERID,">$maffas.perglobleid";
open ALLPERID_H,"> perglobleid_head"; 
my @cneid=split/\//,$maffas;
$cneid[-1]=~s/\.fa$//;
#print "$cneid[-1]====\n";
my $id = $cneid[-1];
#my$id=$id[-1];
foreach ( sort{$a<=>$b} keys %parents_edge){
	$i++;	
	#print "$_||$parents_edge{$_}||$parents[$i-1]","\n";
	my($left,$right)=split/\-/,$parents_edge{$_};
	if($left > $number_child){
		#print "parent: $parents[$left-$number_child-1] $parents[$i-1] $parents[$left-$number_child-1] $i\n";
		$id1 = &getID("$parents[$left-$number_child-1]",$hash_fa{$parents[$i-1]},$hash_fa{$parents[$left-$number_child-1]},$id);
	}else{
		#print "parent: $children[$left-1]  $parents[$i-1] $children[$left-1] $i\n";
	 	$id1 = &getID("$children[$left-1]",$hash_fa{$parents[$i-1]},$hash_fa{$children[$left-1]},$id);
		#$parents_tag{$parents[$_-$number_child-1]}.= $children[$left-1]."-";
	 
	}
	if($right > $number_child){
		#print "parent: $parents[$right-$number_child-1] $parents[$i-1] $parents[$right-$number_child-1] $i\n";
	 	$id2 =  &getID("$parents[$right-$number_child-1]",$hash_fa{$parents[$i-1]},$hash_fa{$parents[$right-$number_child-1]},$id) ;
	}else{
		#print "parent: $children[$right-1] $parents[$i-1] $children[$right-1] $i\n";
	 	$id2 = &getID("$children[$right-1]",$hash_fa{$parents[$i-1]},$hash_fa{$children[$right-1]},$id);
	}
	$id1=~s/$parents[$left-$number_child-1]/$parents_tag{$parents[$left-$number_child-1]}/g,if($parents[$left-$number_child-1]);
	$id2=~s/$parents[$right-$number_child-1]/$parents_tag{$parents[$right-$number_child-1]}/g,if($parents[$right-$number_child-1]);
	print PERIDLOCAL "$id1\n$id2\n";
	#print "$id1\n$id2\n";
}
my @species;
my @ids;
#print "@children\n@parents\n";
foreach my $child(@children){
	#print"child: $child $parents[0] $child\n";
	my $id = &getID("$child",$hash_fa{$parents[0]},$hash_fa{$child},$id);
	my @out=split/\t/,$id;
	push @species,$child;
	push @ids,$out[2];
	#print "$child\n";
}
my $out_species=join"\t",@species;
print ALLPERID_H "species\t$out_species\n";
my $out_ids=join"\t",@ids;
print ALLPERID "$id\t$out_ids\n";
print "open and write files:\n$maffas.perlocalid\n$maffas.perglobleid\nperglobleid_head\n";
close PERIDLOCAL;
close ALLPERID;
close ALLPERID_H;

sub getID{
	my ($species,$ref,$qury,$id)=@_;
	#print "$species||$ref||$qury||$id\n";
	my @seq1=split"",$ref;
	my @seq2=split"",$qury;
	my $len=length($ref);
	my $same=0;
	for(my $i=0;$i<=$#seq1;$i++){
		if($seq1[$i] eq $seq2[$i] && $seq1[$i] =~/[ATCGatcg]/ && $seq2[$i] =~/[ATCGatcg]/){
			$same++;
		}
	}
	my $identity;
	eval { $identity=$same/$len};
	if($@){
		print STDERR "$ref\n$qury\n something wrong !\n";
		exit;
	}else{	
		return "$species\t$id\t$identity\t$len";
	}
}

sub get_parent_tag{
	my $treefile=shift;
        # first remove all #[0-9]*# from the ancestor tree and then run tree_doctor to name the ancestors
        my $call = "set -o pipefail; cat $treefile | sed 's/#[0-9]*#//g' | tree_doctor /dev/stdin -a -n";
        my $namedTree = `$call`;
        cleanDie("ERROR: $call failed\n", $treefile) if ($? != 0 || ${^CHILD_ERROR_NATIVE} != 0);
        chomp($namedTree);
        # now read the prank tree (NOTE: This tree is identical, except for the anc names
        $call = "set -o pipefail; cat $treefile";
        my $prankTree = `$call`;
        cleanDie("ERROR: $call failed\n", $treefile) if ($? != 0 || ${^CHILD_ERROR_NATIVE} != 0);
        chomp($prankTree);
        # This will convert 
        # (((((((mm10:0.08360,rn5:0.08948)#1#:0.22169,speTri2:0.13675)#7#:0.00958,cavPor3:0.23058)#11#:0.02794,oryCun2:0.21242)#14#:0.01413,
        # into 
        # mm10 rn5 #1# speTri2 #7# cavPor3 #11# oryCun2 #14#
        $prankTree =~ s/_[^ ():;,]+//g;
        $prankTree =~ s/:[0-9.]*[,;)]/ /g;
        $prankTree =~ s/\(//g;
        $prankTree =~ s/;//g;
	#----------------------------------
        $namedTree =~ s/_[^ ():;,-]+//g;
        $namedTree =~ s/:[0-9.]*[,;)]/ /g;
        $namedTree =~ s/\(//g;
        $namedTree =~ s/;//g;
        # now split and create the map

        my @prankNodes = split(/[ ]+/, $prankTree);
        my @namedNodes = split(/[ ]+/, $namedTree);
	print "\n@prankNodes\n@namedNodes\n";
	my %AncNum2AncName;
        for (my $i=0; $i<=$#prankNodes; $i++) {
                if ($prankNodes[$i] =~ /#\d+#/) {
                        print "\tmap: $prankNodes[$i] --> $namedNodes[$i]\n";
                        $AncNum2AncName{$prankNodes[$i]} = $namedNodes[$i];
                }else{
                        cleanDie("ERROR in ancestral name mapping: non-ancestral nodes differ in their name: $prankNodes[$i] vs. $namedNodes[$i]\n", $treefile) if ($prankNodes[$i] ne $namedNodes[$i]);
                }
	}
	return %AncNum2AncName;
}

