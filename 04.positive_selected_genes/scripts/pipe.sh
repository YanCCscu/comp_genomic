#bin/bash
#pipeline of psg estimate by codeml
#-prepare aligned genes
#--produce SingleCopyGene info table output file:SingleCopyGeneSets.Ortheogroups_I3.table 
Rscript ../scripts/01.selected_species.R inputs/Ortheogroups_I3.csv inputs/selected_species Tbai 8-16
#--extract gene sequences
../scripts/ExtractGeneSets.py SingleCopyGeneSets.Ortheogroups_I3.table /data/share/yancc/GenoComp/01.orthorfinder/input/cds
#build aligned cds and sge scripts
#sh ../scripts/SeqConvertAlign.sh oneonecds/OG0016326.cds.fa
sh ../scripts/SeqConvertAlign.sh oneonecds 
#build paml scripts 
#sh ../scripts/TrimCodemlSge.sh cdsalign/OG0000081.cds.aligned.fa inputs/hss16.tre Tbai
sh ../scripts/TrimCodemlSge.sh cdsalign inputs/hss16.tre Tbai QEG
#nohup qsub-sge.pl -res vf=1G,p=1 -l 3 -c no -m 100 -j $runmodel $scriptsfile &
sh ../scripts/toupdate/geneanno.sh pamldir SingleCopyGeneSets.Ortheogroups_I3.table
