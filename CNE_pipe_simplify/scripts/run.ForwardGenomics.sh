cmdir=$(cd $(dirname $0);pwd)
curdir=$PWD
((0)) && {
python $cmdir/add_tree_node_label.py $curdir/CNE.tre > $curdir/ForGen/CNE_anc.tre
nw_labels -I $curdir/CNE.tre|awk 'BEGIN{printf("species pheno\n")}{printf("%s 1\n",$1)}'|sed '/Tbai/s/1/0/' > $curdir/ForGen/ID.pheno
awk 'if(NF==13' $curdir/ForGen/all.perglobleid |cat $curdir/ForGen/perglobleid_head - >$curdir/ForGen/allfiltered.pergloble
#add header: branch id pid
cut -f1-3 $curdir/ForGen/all.perlocalid >$curdir/ForGen/allfiltered.per
tail -n +2 $curdir/ForGen/allfiltered.pergloble | cut -d $'\t' -f1 > $curdir/ForGen/ID.list
}
$cmdir/ForwardGenomics-master/forwardGenomics.R \
--tree=$curdir/ForGen/CNE_anc.tre \
--elementIDs=$curdir/ForGen/ID.list \
--listPheno=$curdir/ForGen/ID.pheno \
--globalPid=$curdir/ForGen/allfiltered.pergloble \
--localPid=$curdir/ForGen/all.perlocalid \
--outFile=$curdir/ForGen/CNEOutput.txt \
--verbose=TRUE \
--thresholdConserved=0 \
--outPath=$curdir/ForGen/CNEOUT
