#!/bin/bash
#set -ex
[[ -L $0 ]] && cmdfile=$(ls -l $0 |awk -F " -> " '{print $2}') || cmdfile=$0
cmdir=$(cd $(dirname $cmdfile);pwd)
curdir=$PWD
cnetree=CNE13.tre
CNEDIR=/data/backup/yancc/GitRepo/comp_genomic/CNE_pipe_simplify/scripts
FGDIR=$CNEDIR/ForwardGenomics
((1)) && {
python $cmdir/add_tree_node_label.py $curdir/$cnetree > $curdir/CNE_anc.tre
nw_labels -I $curdir/$cnetree|awk 'BEGIN{printf("species pheno\n")}{printf("%s 1\n",$1)}'|sed -e '/Tbai\|Phum/s/1/0/' > $curdir/ID.pheno
#add header: branch id pid
}

peridlocal=allcne.peridlocal
peridglobal=allcne.peridglobal

#smapleid can not starts with number, let's try to add an A
#[[ $(tail -n +2 allcne.peridglobal|grep -P -c '^A') -lt 1 ]] || sed -i '2,$s/^/A/' $peridglobal 
#[[ $(tail -n +2 allcne.peridlocal|cut -d' ' -f2|grep -P -c '^A') -lt 1 ]] || sed -i '2,$s/ / A/' $peridlocal
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
