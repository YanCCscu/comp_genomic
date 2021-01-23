#PROGRAM_HOME=/data/tools/BGI_tools/BGI_pipelie_update/01.gene_families
PROGRAM_HOME=/data/share/yancc/GenoComp/01.orthorfinder/gene_families
PROGRAM_BIN=$PROGRAM_HOME/bin
export PERL5LIB=$PERL5LIB:/data/nfs/OriginTools/perl5lib:/home/bbg/perl5/lib/perl5

pep_dir=/data/share/yancc/GenoComp/01.orthorfinder/input/pep
cds_dir=/data/share/yancc/GenoComp/01.orthorfinder/input/cds

$PROGRAM_BIN/orthofinder/orthofinder -a 4 -t 80 -f $pep_dir -og -S blast

perl $PROGRAM_BIN/change_format.singlegene.pl $pep_dir/Results_*/Orthogroups.csv  $pep_dir/Results_*/SingleCopyOrthogroups.txt $pep_dir/Results_*/Orthogroups.GeneCount.csv

#Take care of the '>'  in fasta title
perl $PROGRAM_BIN/extract_single_gene.pl $cds_dir $pep_dir/Results_*/SingleCopyOrthogroups.txt.name.txt 24

perl ../gene_families/bin/obtain_4d.pl --dir 4dsites contanated_genes.fa
