#bin/bash
#pipeline of psg estimate by codeml
#-prepare aligned genes
#--produce SingleCopyGene info table output file:SingleCopyGeneSets.Ortheogroups_I3.table 
Rscript ../scripts/01.selected_species.R inputs/Ortheogroups_I3.csv inputs/selected_species Tbai 8-16
#--extract gene sequences
../scripts/ExtractGeneSets.py SingleCopyGeneSets.Ortheogroups_I3.table /data/share/yancc/GenoComp/01.orthorfinder/input/cds
#--choose sequences depend on a tree when sequences are more
#nw_labels -I hss16.tre >label_in_tree
#or
sh ../scripts/SeqConvertAlign.sh cdsalign
#sh ../scripts/SeqConvertAlign.sh oneonecds/OG0016326.cds.fa
sh ../scripts/TrimCodemlSge.sh cdsalign/OG0000081.cds.aligned.fa inputs/hss16.tre Tbai
sh ../scripts/TrimCodemlSge.sh cdsalign inputs/hss16.tre Tbai
#sh ../scripts/TrimCodemlSge.sh cdsalign/OG0000081.cds.aligned.fa inputs/hss16.tre 
