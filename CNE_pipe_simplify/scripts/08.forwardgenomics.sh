cmdir=$(cd $(dirname $0);pwd)
curdir=$PWD

((0)) && {
python $cmdir/add_tree_node_label.py $curdir/CNE.tre > $curdir/CNE_anc.tre
nw_labels -I $curdir/CNE.tre|awk 'BEGIN{printf("species pheno\n")}{printf("%s 1\n",$1)}'|sed '/Tbai/s/1/0/' > $curdir/ID.pheno
#add header: branch id pid
}

peridlocal=allcne.peridlocal
peridglobal=allcne.peridglobal

#peridlocal=OneTest.local
#peridglobal=OneTest.global
#awk 'NF==13' $peridglobal|tail -n +2|cut -d $'\t' -f1 >ID.list
cat $peridglobal|tail -n +2|cut -d ' ' -f1 >ID.list

../tools/ForwardGenomics/forwardGenomics.R \
--tree=$curdir/CNE_anc.tre \
--elementIDs=$curdir/ID.list \
--expectedPerIDs=$curdir/../tools/ForwardGenomics/lookUpData/expPercentID_CNE.txt \
--weights=$curdir/../tools/ForwardGenomics/lookUpData/branchWeights_CNE.txt \
--method=all \
--minLosses=1 \
--listPheno=$curdir/ID.pheno \
--globalPid=$curdir/$peridglobal \
--localPid=$curdir/$peridlocal \
--outFile=$curdir/Output.txt \
--outPath=$curdir/outpath \
--verbose=TRUE \
--thresholdConserved=0 
