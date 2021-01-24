#!/bin/bash
[[ $# -lt 2 ]] && echo -e "sh $0 pamldir SingleCopyGeneSets.Ortheogroups_I3.table" && exit
cmdir=$(cd $(dirname $0);pwd)
#tooldir=$cmdir/scripts
tooldir=/data/share/yancc/GenoComp/04.Positive_Selective_Test/NewRun2/scripts
pamldir=$1
Orthogroups=$2
SigGeneList=lnLout.SigGeneList
[[ $# -ge 3 ]] && c=$3 || c=3
cat $pamldir/*/*.lnL.log|awk '$5<0.05 && $5>0' >$SigGeneList
awk -F"\t" -v OFS="\t" '{$1=gensub(/.*(OG[0-9]+).+/,"\\1",$1);print $0}' $SigGeneList|sort >${SigGeneList}.rename
tail -n +2 $Orthogroups|awk -F '\t' '{printf("%s\t%s\n",$1,$2)}' |sort >${Orthogroups}.rename
join -t $'\t' -a2 -11 -21 ${Orthogroups}.rename ${SigGeneList}.rename >joined_lnL_ortho.table
annodir=/data/share/yancc/GenoComp/04.Positive_Selective_Test/NewRun2/scripts
cat joined_lnL_ortho.table|./add_annoinfo.py $annodir/Tbai_geneanno.list $annodir/Tbai.pep_hsa_gid.table 2 >lnLout.SigGeneList.anno

echo "now, output file to lnLout.SigGeneList.anno" 
#sort -t $'\t' -k2,2g SigGeneList |less -S

