#!/usr/bin/perl -w
my($pep_dir,$cds_dir,$cpu1,$cpu2,$cpu3,$align_tools); 
$align_tools="blast";
use Getopt::Long;
use File::Spec;
use Env qw(PATH);
$cpu1=$cpu2=$cpu3=4;
my $path_curf = File::Spec->rel2abs(__FILE__);
my ($vol, $dir, $file) = File::Spec->splitpath($path_curf);
GetOptions(
        "pep|p:s"=>\$pep_dir,
        "cds|c:s"=>\$cds_dir,
        "cpu1:s"=>\$cpu1,
        "cpu2:s"=>\$cpu2,
        "cpu3:s"=>\$cpu3,
	"align|a:s"=>\$align_tools,
        "help|?"=>\&USAGE,
);
unless($pep_dir && $cds_dir){
        &USAGE;
}
### run orthofinder
#print "export PATH=$dir/orthofinder\:\$PATH\n";
$PATH="$dir/orthofinder:$PATH";
`rm -rf $pep_dir/Results_*/`;
print "orthofinder is running ... \nIt will take sevaral hours or days\n";
my $sig=system("$dir/orthofinder/orthofinder -a $cpu1 -t $cpu2 -f $pep_dir -og -S $align_tools");
if($sig==0){
	print "orthofinder finished successfully!\n";
}else{
	print "orthofinder failed !\n";
	exit;
}
### deal with orthofinder output 
system("perl $dir/change_format.singlegene.pl $pep_dir/Results_*/Orthogroups.csv  $pep_dir/Results_*/SingleCopyOrthogroups.txt $pep_dir/Results_*/Orthogroups.GeneCount.csv");
system("perl $dir/extract_single_gene.pl $cds_dir $pep_dir/Results_*/SingleCopyOrthogroups.txt.name.txt $cpu3");
system("perl $dir/obtain_4d.pl contanated_genes.fa");
print "finished! results are:
	contanated_genes.fa (for 02.phylogeny)
	contanated_genes.fa.4d (for 02.phylogeny)
	*.cafe (for 05.genefamily_expansion)
	*.paml (for Paml_PiPe_get_positivegenes)
All one to one singlecopy genes are stored in family_split_cds dir\n";
sub USAGE{
    my $usage=<<"USAGE";
Name:
    $0  
Description:
	#author: pcj 2020.4.20 finished.
	This script is to run orthofinder to identify gene families.
Usage:
    options:
    --pep|-p	<string> 	path for *.pep files
    --cds|-c	<string> 	path for *.cds files
    --cpu1	<int>		for orthofinder "-a" option (defaut: 4)   
    --cpu2	<int>		for orthofinder "-t" option(cpus to run blastp) (defaut: 4) 
    --cpu3      <int>		threads for gene contanating  (defaut: 4) 
    --align	<string>	align tools(blast,diamond) (defaut: blast)
    --help|-h|?                 print this information 
    --re_species|-re   <string> the reference species
Example:
perl $0 -p /data/tools/BGI_tools/BGI_pipelie_update/01.gene_families/input/pep -c /data/tools/BGI_tools/BGI_pipelie_update/01.gene_families/input/cds --cpu1 10 --cpu2 100 --cpu3 60
USAGE
   print $usage;
   exit;
}
