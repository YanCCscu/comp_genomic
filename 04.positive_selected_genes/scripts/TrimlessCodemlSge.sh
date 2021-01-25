#!/bin/bash
[[ $# -lt 3 ]] && { echo -e "sh $0 incds.fa|incds.dir intree forground_sp [PSG|QEG] [suffix] <--default: aligned.fa"; \
echo -e "\t>>either dir contain cds fasta or single fasta file is ok"; \
echo -e "\t>>fgsp: one or more foreground species, multispecies should be divided by |, like 'sp1|sp2|...'"; } && exit 1;
[[ $# -ge 4 ]] && runmodel=$4 || runmodel=PSG
[[ $# -ge 5 ]] && suffix=$5 || suffix=aligned.fa
toolsdir=$(cd $(dirname $0);pwd)
workdir=$(pwd)
outdir=$workdir/pamldir
[[ ! -d $outdir ]] && mkdir -p $outdir
#-------------------------------
[[ -f $1 ]] && alignedfas=($(cd $(dirname $1);pwd)/$(basename $1))
[[ -d $1 ]] && alignedfas=($(cd $1;pwd)/*.${suffix})
intree=$2
fgsp=$3
count=1
###make sge qsub shell
for alignedfa in ${alignedfas[@]}
do 
#-----------------
echo "#${count}#----make codeml control files for $alignedfa ..." && let count++
namekey=$(basename ${alignedfa%.*})
[[ ! -d $outdir/$namekey ]] && mkdir -p $outdir/$namekey
sed -i 's/|/ /' $alignedfa
$toolsdir/trimal \
-automated1 \
-in $alignedfa \
-out $outdir/$namekey/${namekey}.trimal.fasta \
-htmlout $outdir/$namekey/${namekey}.trimal.html \
-colnumbering >$outdir/$namekey/${namekey}.trimal.cols
#-resoverlap 0.50 \
#-seqoverlap 50 \

grep ">" $outdir/$namekey/${namekey}.trimal.fasta | cut -c 2- > $outdir/$namekey/id.list
#skip alignment without forground species
fgsp_array=(${fgsp//|/ })
if [[ $(grep -c -P "$fgsp" $outdir/$namekey/id.list) -lt ${#fgsp_array[@]} ]]
then
	echo "$alignedfa not all forground species left after trim, so skip it ..." >> gene_failed.log 
	continue
fi
$toolsdir/trimal -phylip_paml \
-in $outdir/$namekey/${namekey}.trimal.fasta \
-out $outdir/$namekey/${namekey}.trimal.phy
fgsp_reg=$(echo $fgsp|sed 's/|/\\|/g')
$toolsdir/nw_prune -v -f $intree $outdir/$namekey/id.list |sed "s/\($fgsp_reg\)/\1 #1/g" >$outdir/$namekey/${namekey}.trimal.tre
#or
#nw_clade hss16.tre $(cat id.list) >EPAS1.cds.prank.trimal.tre
[[ "$runmodel" == "PSG" ]] && scriptsfile=psg.sge.sh || scriptsfile=qeg.sge.sh
[[ "$runmodel" == "PSG" ]] && runscripts=apply_site_branch.sh || runscripts=apply_branch.sh
cat <<EOF >>$scriptsfile
cd $outdir/$namekey/
sh $toolsdir/$runscripts -a ${namekey}.trimal.phy -t ${namekey}.trimal.tre
$toolsdir/cal_LRT.py ${namekey}.trimal.nul.mlc ${namekey}.trimal.alt.mlc >${namekey}.lnL.log
EOF
#------------------
done

echo -e "Now you can submit batchfile to sge cluster with command like:\n";
echo -e "nohup qsub-sge.pl -res vf=1G,p=1 -l 3 -c no -m 100 -j $runmodel $scriptsfile &\n"
echo -e "Finaly!!! you can 'cat $outdir/*/*.lnL.log to collect lnL out info'"
