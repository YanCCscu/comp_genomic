#!/bin/bash
[[ $# -lt 2 ]] && echo "sh $0 incds.fa|incds.dir intree [suffix] <--default: aligned.fa" && exit 1;
[[ $# -ge 3 ]] && suffix=$3 || suffix=aligned.fa
toolsdir=$(cd $(dirname $0);pwd)
workdir=$(pwd)
outdir=$workdir/pamldir
[[ ! -d $outdir ]] && mkdir -p $outdir
#-------------------------------
[[ -f $1 ]] && alignedfas=($(cd $(dirname $1);pwd)/$(basename $1))
[[ -d $1 ]] && alignedfas=($(cd $1;pwd)/*.${suffix})
intree=$2
###make sge qsub shell
for alignedfa in ${alignedfas[@]}
do 
#-----------------
echo "make scripts for $alignedfa ..."
namekey=$(basename ${alignedfa%.*})
[[ ! -d $outdir/$namekey ]] && mkdir -p $outdir/$namekey
sed -i 's/|/ /' $alignedfa
$toolsdir/trimal -automated1 \
-in $alignedfa \
-resoverlap 0.75 \
-seqoverlap 85 \
-out $outdir/$namekey/${namekey}.trimal.fasta \
-htmlout $outdir/$namekey/${namekey}.trimal.html \
-colnumbering >$outdir/$namekey/${namekey}.trimal.cols

grep ">" $outdir/$namekey/${namekey}.trimal.fasta | cut -c 2- > $outdir/$namekey/id.list

$toolsdir/trimal -phylip_paml \
-in $outdir/$namekey/${namekey}.trimal.fasta \
-out $outdir/$namekey/${namekey}.trimal.phy

$toolsdir/nw_prune -v -f $intree $outdir/$namekey/id.list |sed 's/Tbai/Tbai #1/' >$outdir/$namekey/${namekey}.trimal.tre
#or
#nw_clade hss16.tre $(cat id.list) >EPAS1.cds.prank.trimal.tre
cat <<EOF >>psg.sge.sh
cd $outdir/$namekey/
sh $toolsdir/apply_site_branch.sh -a ${namekey}.trimal.phy -t ${namekey}.trimal.tre
$toolsdir/cal_LRT.py ${namekey}.trimal.nul.mlc ${namekey}.trimal.alt.mlc >${namekey}.lnL.log
EOF
#------------------
done

echo -e "Now you can submit batchfile to sge cluster with command like:\n";
echo -e "nohup qsub-sge.pl -res vf=1G,p=1 -l 3 -c no -m 100 -j psg psg.sge.sh &\n"
echo -e "cat $outdir/*/*.lnL.log to collect lnL out info"
