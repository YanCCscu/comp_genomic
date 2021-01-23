#!/bin/bash
[[ $# -lt 1 ]] && echo "sh $0 incds.fa|incds.dir [suffix] <-- default:cds.fa" && exit 1;
[[ $# -ge 2 ]] && suffix=$2 || suffix=cds.fa
[[ -f $1 ]] && incds=($(cd $(dirname $1);pwd)/$(basename $1))
[[ -d $1 ]] && incds=($(cd $1;pwd)/*.${suffix})
toolsdir=$(cd $(dirname $0);pwd)
workdir=$(pwd)
outdir=$workdir/cdsalign
[[ ! -d $outdir ]] && mkdir -p $outdir
[[ -f aligned.sge.sh ]] && rm aligned.sge.sh
for cds in ${incds[@]}
do
basecds=$(basename $cds) && basecds=${basecds%.*}
cat <<EOF >>aligned.sge.sh
perl $toolsdir/cds2pep_zy.pl -f $cds -o $outdir/${basecds}.pep.fa -c 1
$toolsdir/prank-msa/bin/prank -d=$outdir/${basecds}.pep.fa -o=$outdir/${basecds}.pep -quiet
$toolsdir/RevTrans-1.4/revtrans.py $cds $outdir/${basecds}.pep.best.fas >$outdir/${basecds}.aligned.fa
rm $outdir/${basecds}.pep.fa #$outdir/${basecds}.pep.best.fas
EOF
done

echo -e "Now you can submit batchfile to sge cluster with command like:\n";
echo -e "nohup qsub-sge.pl -res vf=1G,p=1 -l 4 -c no -m 100 -j aligned aligned.sge.sh &\n"

#other options to choose
#align with maff more faster
#/usr/bin/mafft-linsi EPAS1.pep.fa >EPAS1.pep.ali
#convert pep to cds by matched name will skip stop codon warning: 
#$toolsdir/RevTrans-1.4/revtrans.py -match name -readthroughstop $cds $outdir/${basecds}.pep.best.fas >$outdir/${basecds}.aligned.fa
#or
