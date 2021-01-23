#!/usr/bin/perl
use File::Spec;
my $path_curf = File::Spec->rel2abs(__FILE__);
my ($vol, $dir, $file) = File::Spec->splitpath($path_curf);
die "perl $0 <pep>\n" if $ARGV<0;
my $pep=shift;
my $pep_prank="$pep.best.fas";
my $pep_prank_trimal="$pep.best.fas.trimal";
my $pep_prank_html="$pep.best.fas.trimal.html";

#my $pep_prank_2="$pep.pep.prank.fasta.mark.2";
#my $pep_2="$pep.2";
    #}
system("$dir/prank/prank -d=$pep -o=$pep -showtree -quiet") and die "can not execute prank! $pep error\n";
#system("$dir/trimal/trimal -in $pep_prank -noallgaps -out $pep_prank_trimal -fasta -htmlout $pep_prank_html") and die "can not execute trimal! $pep_prank! \n";

system("$dir/trimal/trimal -in $pep_prank -automated1 -out $pep_prank_trimal -fasta -htmlout $pep_prank_html") and die "can not execute trimal! $pep_prank! \n";
