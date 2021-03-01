cmdir=$(cd $(dirname $0);pwd)
curdir=$PWD
FGDIR=/data/backup/yancc/GitRepo/comp_genomic/CNE_pipe_simplify/scripts/ForwardGenomics
((0)) && {
python $cmdir/add_tree_node_label.py $curdir/CNE.tre > $curdir/CNE_anc.tre
nw_labels -I $curdir/CNE.tre|awk 'BEGIN{printf("species pheno\n")}{printf("%s 1\n",$1)}'|sed '/Tbai/s/1/0/' > $curdir/ID.pheno
#add header: branch id pid
}

peridlocal=allcne.peridlocal
peridglobal=allcne.peridglobal

[[ $(tail -n +2 allcne.peridglobal|grep -P -c '^A') -gt 1 ]] || sed -i '2,$s/^/A/' $peridglobal 
[[ $(tail -n +2 allcne.peridlocal|cut -d' ' -f2|grep -P -c '^A') -gt 1 ]] || sed -i '2,$s/ / A/' $peridlocal
cat $peridglobal|tail -n +2|cut -d ' ' -f1 >ID.list

#peridlocal=OneTest.local
#peridglobal=OneTest.global
#awk 'NF==13' $peridglobal|tail -n +2|cut -d $'\t' -f1 >ID.list
#warning: The element id should begin with character, not number

((1)) && {
$FGDIR/forwardGenomics.R \
--tree=$curdir/CNE_anc.tre \
--elementIDs=$curdir/ID.list \
--expectedPerIDs=$FGDIR/lookUpData/expPercentID_CNE.txt \
--weights=$FGDIR/lookUpData/branchWeights_CNE.txt \
--method=all \
--minLosses=1 \
--listPheno=$curdir/ID.pheno \
--globalPid=$curdir/$peridglobal \
--localPid=$curdir/$peridlocal \
--outFile=$curdir/AllOutput.txt \
--outPath=$curdir/outpath_all \
--verbose=TRUE \
--thresholdConserved=0 
}


((0)) && {
cat $peridglobal|tail -n +2|cut -d ' ' -f1 >ID.list
$FGDIR/forwardGenomics.R \
--tree=$curdir/CNE_anc.tre \
--elementIDs=$curdir/ID.list \
--expectedPerIDs=$FGDIR/lookUpData/expPercentID_CNE.txt \
--weights=$FGDIR/lookUpData/branchWeights_CNE.txt \
--method=branch \
--minLosses=1 \
--listPheno=$curdir/ID.pheno \
--globalPid=$curdir/$peridglobal \
--localPid=$curdir/$peridlocal \
--outFile=$curdir/BranchOutput.txt \
--outPath=$curdir/outpath_branch \
--verbose=TRUE \
--thresholdConserved=0 
}
