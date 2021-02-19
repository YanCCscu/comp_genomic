#bin/bash
#pipeline of psg estimate by codeml
#---------------check stats function
CheckStat(){
        printf -- 'checking sge stats for jobs %s ...\n' $1
        sleep 5
        DONE=0;
        while [ $DONE -eq 0 ]
        do
                running=$(qstat -f|grep -c $1)
                if [ "$running" = "0" ]; then DONE=1; fi
                printf -- '.'
                sleep 5
        done
        printf -- '\nDONE!\n'
}
#-prepare aligned genes
#--produce SingleCopyGene info table output file:SingleCopyGeneSets.Ortheogroups_I3.table 
Rscript ../scripts/01.selected_species.R inputs/Ortheogroups_I3.csv inputs/selected_species Tbai 8-16
#--extract gene sequences
../scripts/ExtractGeneSets.py SingleCopyGeneSets.Ortheogroups_I3.table /data/share/yancc/GenoComp/01.orthorfinder/input/cds
#--choose sequences depend on a tree when sequences are more
#nw_labels -I hss16.tre >label_in_tree
#or
sh ../scripts/SeqConvertAlign.sh oneonecds 
nohup qsub-sge.pl -res vf=1G,p=1 -l 4 -c no -m 100 -j alignedS1 aligned.sge.sh &
CheckStat alignedS1
#sh ../scripts/SeqConvertAlign.sh oneonecds/OG0016326.cds.fa
#sh ../scripts/TrimCodemlSge.sh cdsalign/OG0000081.cds.aligned.fa inputs/hss16.tre Tbai
#reroot trees:
#nw_reroot 4dsites/contanated_genes.fa.4d.contree Pmur Ggal|nw_display -
nw_reroot 4dsites/contanated_genes.fa.4d.contree Cmyd Ggal >species.tre
sh ../scripts/TrimCodemlSge.sh cdsalign inputs/hss16.tre Tbai
#sh ../scripts/TrimlessCodemlSge.sh cdsalign inputs/hss16.tre Tbai PSG
nohup qsub-sge.pl -res vf=1G,p=1 -l 3 -c no -m 100 -j psg psg.sge.sh &
#sh ../scripts/TrimCodemlSge.sh cdsalign/OG0000081.cds.aligned.fa inputs/hss16.tre 
sh ../scripts/toupdate/geneanno.sh pamldir SingleCopyGeneSets.Ortheogroups_I3.table
